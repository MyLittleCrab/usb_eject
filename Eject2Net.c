#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libusb-1.0/libusb.h>
#include <stdint.h>

#define CBW_SIGNATURE 0x43425355UL
#define CSW_SIGNATURE 0x53425355UL

struct __attribute__((packed)) cbw {
    uint32_t dCBWSignature;
    uint32_t dCBWTag;
    uint32_t dCBWDataTransferLength;
    uint8_t  bmCBWFlags;
    uint8_t  bCBWLUN;
    uint8_t  bCBWCBLength;
    uint8_t  CBWCB[16];
};

struct __attribute__((packed)) csw {
    uint32_t dCSWSignature;
    uint32_t dCSWTag;
    uint32_t dCSWDataResidue;
    uint8_t  bCSWStatus;
};

typedef struct {
    uint16_t vid;
    uint16_t pid;
} device_entry;

// ======= FIND MASS STORAGE ENDPOINTS =======
int find_mass_storage_endpoints(libusb_device *dev, int iface, unsigned char *ep_out, unsigned char *ep_in) {
    struct libusb_config_descriptor *cfg;
    if (libusb_get_active_config_descriptor(dev, &cfg) != 0) return -1;

    for (int i = 0; i < cfg->bNumInterfaces; i++) {
        const struct libusb_interface *intf = &cfg->interface[i];
        for (int alt = 0; alt < intf->num_altsetting; alt++) {
            const struct libusb_interface_descriptor *desc = &intf->altsetting[alt];
            if (desc->bInterfaceNumber == iface && desc->bInterfaceClass == 0x08) { // Mass Storage
                for (int e = 0; e < desc->bNumEndpoints; e++) {
                    const struct libusb_endpoint_descriptor *ed = &desc->endpoint[e];
                    if ((ed->bmAttributes & LIBUSB_TRANSFER_TYPE_MASK) == LIBUSB_TRANSFER_TYPE_BULK) {
                        if (ed->bEndpointAddress & LIBUSB_ENDPOINT_IN) *ep_in = ed->bEndpointAddress;
                        else *ep_out = ed->bEndpointAddress;
                    }
                }
                libusb_free_config_descriptor(cfg);
                return 0;
            }
        }
    }

    libusb_free_config_descriptor(cfg);
    return -1;
}

// ======= SEND STANDARD EJECT =======
int eject_device(uint16_t vid, uint16_t pid) {
    libusb_context *ctx = NULL;
    int rc = libusb_init(&ctx);
    if (rc != 0) {
        fprintf(stderr, "libusb_init failed: %d\n", rc);
        return 1;
    }

    libusb_device_handle *handle = libusb_open_device_with_vid_pid(ctx, vid, pid);
    if (!handle) { fprintf(stderr, "Device %04x:%04x not found\n", vid, pid); libusb_exit(ctx); return 1; }

    libusb_device *dev = libusb_get_device(handle);
    unsigned char ep_out = 0, ep_in = 0;

    int iface = -1;

    struct libusb_config_descriptor *cfg;
    if (libusb_get_active_config_descriptor(dev, &cfg) == 0) {
        int found = 0;
        for (int i=0; i<cfg->bNumInterfaces && !found; i++) {
            const struct libusb_interface *intf = &cfg->interface[i];
            for (int alt=0; alt<intf->num_altsetting && !found; alt++) {
                const struct libusb_interface_descriptor *desc = &intf->altsetting[alt];
                if (desc->bInterfaceClass == 0x08) { // Mass Storage
                    iface = desc->bInterfaceNumber;
                    found = 1;
                }
            }
        }
        libusb_free_config_descriptor(cfg);
    }

    if (iface < 0) {
        fprintf(stderr, "No Mass Storage interface found!\n");
        libusb_close(handle); libusb_exit(ctx); return 1;
    }

    if (find_mass_storage_endpoints(dev, iface, &ep_out, &ep_in) != 0) {
        fprintf(stderr, "Mass Storage endpoints not found on iface %d\n", iface);
        libusb_close(handle); libusb_exit(ctx); return 1;
    }

    printf("Using interface %d: ep_out=0x%02x ep_in=0x%02x\n", iface, ep_out, ep_in);

    int claimed = 0;
    if (libusb_kernel_driver_active(handle, iface) == 1) {
        libusb_detach_kernel_driver(handle, iface);
    }
    rc = libusb_claim_interface(handle, iface);
    if (rc != 0) {
        fprintf(stderr, "Cannot claim interface %d: %d\n", iface, rc);
        libusb_close(handle); libusb_exit(ctx); return 1;
    }
    claimed = 1;

    struct cbw cb;
    memset(&cb, 0, sizeof(cb));
    cb.dCBWSignature = CBW_SIGNATURE;
    cb.dCBWTag = 0xdeadbeef;
    cb.dCBWDataTransferLength = 0;
    cb.bmCBWFlags = 0x00;
    cb.bCBWLUN = 0;
    cb.bCBWCBLength = 6;
    cb.CBWCB[0] = 0x1B; // SCSI START/STOP UNIT
    cb.CBWCB[4] = 0x01; // LoEj=1 -> eject

    int transferred;
    fflush(stdout);
    int r = libusb_bulk_transfer(handle, ep_out, (unsigned char*)&cb, sizeof(cb), &transferred, 2000);
    if (r != 0) { fprintf(stderr, "Bulk transfer CBW failed: %d\n", r); goto cleanup; }
    printf("CBW sent (%d bytes)\n", transferred);
    fflush(stdout);

    struct csw cs;
    r = libusb_bulk_transfer(handle, ep_in, (unsigned char*)&cs, sizeof(cs), &transferred, 2000);
    if (r != 0) { fprintf(stderr, "Bulk transfer CSW failed: %d\n", r); goto cleanup; }
    if (cs.dCSWSignature != CSW_SIGNATURE) { fprintf(stderr, "Bad CSW signature\n"); goto cleanup; }

    printf("Eject command successful, CSW status=0x%02x\n", cs.bCSWStatus);

cleanup:
    if (claimed) {
        int rc2 = libusb_release_interface(handle, iface);
        if (rc2 != 0) fprintf(stderr, "Warning: release_interface returned %d\n", rc2);
    }
    libusb_close(handle);
    libusb_exit(ctx);
    return 0;
}

// ======= MAIN =======
int main(int argc, char *argv[]) {
    // If two arguments: treat as VID PID and eject immediately
    if (argc == 3) {
        uint16_t vid = (uint16_t)strtol(argv[1], NULL, 16);
        uint16_t pid = (uint16_t)strtol(argv[2], NULL, 16);
        printf("Ejecting device %04x:%04x ...\n", vid, pid);
        return eject_device(vid, pid);
    }

    int only_list = 0;
    if (argc > 1 && strcmp(argv[1], "--only-list") == 0) {
        only_list = 1;
    }

    libusb_context *ctx;
    libusb_init(&ctx);

    libusb_device **devs;
    ssize_t cnt = libusb_get_device_list(ctx, &devs);
    if (cnt < 0) { fprintf(stderr, "Error getting device list\n"); return 1; }

    device_entry *entries = calloc(cnt, sizeof(device_entry));
    int index = 0;

    if (!only_list){
        printf("Connected USB devices:\n");
    }
    for (ssize_t i=0; i<cnt; i++) {
        struct libusb_device_descriptor desc;
        if (libusb_get_device_descriptor(devs[i], &desc) != 0) continue;

        printf("%2d) VID:PID = %04x:%04x", index+1, desc.idVendor, desc.idProduct);

        libusb_device_handle *h;
        if (libusb_open(devs[i], &h) == 0) {
            unsigned char buf[256];
            if (desc.iManufacturer && libusb_get_string_descriptor_ascii(h, desc.iManufacturer, buf, sizeof(buf)) > 0)
                printf(" | Manufacturer: %s", buf);
            if (desc.iProduct && libusb_get_string_descriptor_ascii(h, desc.iProduct, buf, sizeof(buf)) > 0)
                printf(" | Product: %s", buf);
            libusb_close(h);
        }

        printf("\n");

        entries[index].vid = desc.idVendor;
        entries[index].pid = desc.idProduct;
        index++;
    }

    if (index == 0) {
        printf("No USB devices found.\n");
        libusb_free_device_list(devs, 1);
        libusb_exit(ctx);
        free(entries);
        return 0;
    }

    if (only_list) {
        libusb_free_device_list(devs, 1);
        libusb_exit(ctx);
        free(entries);
        return 0;
    }

    printf("\nEnter the number of device to eject: ");
    int choice;
    if (scanf("%d", &choice) != 1 || choice < 1 || choice > index) {
        printf("Invalid selection.\n");
        libusb_free_device_list(devs, 1);
        libusb_exit(ctx);
        free(entries);
        return 1;
    }

    uint16_t vid = entries[choice-1].vid;
    uint16_t pid = entries[choice-1].pid;

    printf("Ejecting device %04x:%04x ...\n", vid, pid);
    eject_device(vid, pid);

    libusb_free_device_list(devs, 1);
    libusb_exit(ctx);
    free(entries);
    return 0;
}

