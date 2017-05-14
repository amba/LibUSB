#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <libusb.h>

#include "const-c.inc"

typedef libusb_context *LibUSB;
typedef libusb_device *LibUSB__Device;
typedef libusb_device_handle *LibUSB__Device__Handle;

static void
do_not_warn_unused(void *x __attribute__((__unused__)))
{
}


#define CROAK(arg1, ...) \
    call_va_list("Carp::croak", arg1, ## __VA_ARGS__, NULL)
#define CARP(arg1, ...) \
    call_va_list("Carp::carp", arg1, ## __VA_ARGS__, NULL)

static void
call_va_list(char *func, char *arg1, ...)
{
    va_list ap;
    va_start(ap, arg1);
    
    /* See perlcall.  */
    dSP;
    
    ENTER;
    SAVETMPS;
    
    PUSHMARK(SP);
    mXPUSHp(arg1, strlen(arg1));
    while (1) {
        char *arg = va_arg(ap, char *);
        if (arg == NULL)
            break;
        mXPUSHp(arg, strlen(arg));
    }
    PUTBACK;

    call_pv(func, G_DISCARD);

    FREETMPS;
    LEAVE;
}

static void
handle_error(ssize_t errcode, const char *function_name)
{
    /* Some functions like libusb_get_device_list return positive numbers
     on success. So do not check for == 0.  */
    if (errcode >= 0)
        return;
    const char *error = libusb_strerror(errcode);
    CROAK("Error in ", function_name, ": ", error);
}

static HV *
interface_descriptor_to_HV(struct libusb_interface_descriptor *interface)
{

}

static AV *
interface_array_to_AV(struct libusb_interface *interface)
{
  AV *rv = newAV();
  int i;
  for (int i = 0; i < interface->num_altsetting; ++i) {
  av_push(rv, interface->altsetting;

  
}

static HV *
config_descriptor_to_HV(struct libusb_config_descriptor *config)
{
    HV *rv = newHV();
    hv_stores(rv, "bLength", newSVuv(config->bLength));
    hv_stores(rv, "bDescriptorType", newSVuv(config->bDescriptorType));
    hv_stores(rv, "wTotalLength", newSVuv(config->wTotalLength));
    hv_stores(rv, "bNumInterfaces", newSVuv(config->bNumInterfaces));
    hv_stores(rv, "bConfigurationValue", newSVuv(config->bConfigurationValue));
    hv_stores(rv, "iConfiguration", newSVuv(config->iConfiguration));
    hv_stores(rv, "bmAttributes", newSVuv(config->bmAttributes));
    hv_stores(rv, "MaxPower", newSVuv(config->MaxPower));
    hv_stores(rv, "interface", interface_array_to_AV(config->interface));
    hv_stores(rv, "extra", newSVpvn(config->extra, config->extra_length));
    return rv;
}

MODULE = LibUSB		PACKAGE = LibUSB	 PREFIX = libusb_	

INCLUDE: const-xs.inc

LibUSB
libusb_init(char *class)
CODE:
    LibUSB ctx;
    do_not_warn_unused(class);
    int rv = libusb_init(&ctx);
    handle_error(rv, "libusb_init");
    RETVAL = ctx;
OUTPUT:
    RETVAL


void
libusb_set_debug(LibUSB ctx, int level)
CODE:
    libusb_set_debug(ctx, level);
    






void
libusb_get_device_list(LibUSB ctx)
PPCODE:
    libusb_device **list;
    ssize_t num = libusb_get_device_list(ctx, &list);
    handle_error(num, "libusb_get_device_list");
    size_t i;
    for (i = 0; i < num; ++i) {
        SV *tmp = newSV(0);
        sv_setref_pv(tmp, "LibUSB::Device", (void *) list[i]);
        mXPUSHs(tmp);
    }
    libusb_free_device_list(list, 0);

LibUSB::Device::Handle
libusb_open_device_with_vid_pid(LibUSB ctx, unsigned vendor_id, unsigned product_id)
CODE:
    libusb_device_handle *handle;
    handle = libusb_open_device_with_vid_pid(ctx, vendor_id, product_id);
    if (handle == NULL)
        CROAK("Error in libusb_open_device_with_vid_pid.",
              " use libusb_open for detailed error message.");
    RETVAL = handle;
OUTPUT:
    RETVAL
        
void
DESTROY(LibUSB ctx)
CODE:
    libusb_exit(ctx);


MODULE = LibUSB      PACKAGE = LibUSB::Device       PREFIX = libusb_

unsigned
libusb_get_bus_number(LibUSB::Device dev)

unsigned
libusb_get_port_number(LibUSB::Device dev)

void
libusb_get_port_numbers(LibUSB::Device dev)
PPCODE:
    int len = 20;
    uint8_t port_numbers[len];
    int num = libusb_get_port_numbers(dev, port_numbers, len);
    handle_error(num, "libusb_get_port_numbers");
    int i;
    for (i = 0; i < num; ++i) {
        mXPUSHu(port_numbers[i]);
    }

LibUSB::Device
libusb_get_parent(LibUSB::Device dev)

unsigned
libusb_get_device_address(LibUSB::Device dev)

int
libusb_get_device_speed(LibUSB::Device dev)

int
libusb_get_max_packet_size(LibUSB::Device dev, unsigned char endpoint)
CODE:
    int rv = libusb_get_max_packet_size(dev, endpoint);
    handle_error(rv, "libusb_get_max_packet_size");
    RETVAL = rv;
OUTPUT:
    RETVAL

    
LibUSB::Device
libusb_ref_device(LibUSB::Device dev)


void
libusb_unref_device(LibUSB::Device dev)


LibUSB::Device::Handle
libusb_open(LibUSB::Device dev)
CODE:
    libusb_device_handle *handle;
    int rv = libusb_open(dev, &handle);
    handle_error(rv, "libusb_open");
    RETVAL = handle;
OUTPUT:
    RETVAL


HV *
libusb_get_device_descriptor(LibUSB::Device dev)
CODE:
    struct libusb_device_descriptor desc;
    int rv = libusb_get_device_descriptor(dev, &desc);
    handle_error(rv, "libusb_get_device_descriptor");
    HV *retval = newHV();
    hv_stores(retval, "bLength", newSVuv(desc.bLength));
    hv_stores(retval, "bDescriptorType", newSVuv(desc.bDescriptorType));
    hv_stores(retval, "bcdUSB", newSVuv(desc.bcdUSB));
    hv_stores(retval, "bDeviceClass", newSVuv(desc.bDeviceClass));
    hv_stores(retval, "bDeviceSubClass", newSVuv(desc.bDeviceSubClass));
    hv_stores(retval, "bDeviceProtocol", newSVuv(desc.bDeviceProtocol));
    hv_stores(retval, "bMaxPacketSize0", newSVuv(desc.bMaxPacketSize0));
    hv_stores(retval, "idVendor", newSVuv(desc.idVendor));
    hv_stores(retval, "idProduct", newSVuv(desc.idProduct));
    hv_stores(retval, "bcdDevice", newSVuv(desc.bcdDevice));
    hv_stores(retval, "iManufacturer", newSVuv(desc.iManufacturer));
    hv_stores(retval, "iProduct", newSVuv(desc.iProduct));
    hv_stores(retval, "iSerialNumber", newSVuv(desc.iSerialNumber));
    hv_stores(retval, "bNumConfigurations", newSVuv(desc.bNumConfigurations));
    RETVAL = retval;
OUTPUT:
    RETVAL

HV *
libusb_get_active_config_descriptor(LibUSB::Device dev)
CODE:
    struct libusb_config_descriptor *config;
    int rv = libusb_get_active_config_descriptor(dev, &config);
    handle_error(rv, "libusb_get_active_config_descriptor");
    RETVAL = config_descriptor_to_HV(config);
    libusb_free_config_descriptor(config);
OUTPUT:
    RETVAL


void
DESTROY(LibUSB::Device dev)
CODE:
    libusb_unref_device(dev);






MODULE = LibUSB      PACKAGE = LibUSB::Device::Handle       PREFIX = libusb_

LibUSB::Device
libusb_get_device(LibUSB::Device::Handle dev_handle)

int
libusb_get_configuration(LibUSB::Device::Handle dev)
CODE:
    int config;
    int rv = libusb_get_configuration(dev, &config);
    handle_error(rv, "libusb_get_configuration");
    RETVAL = config;
OUTPUT:
    RETVAL

void
libusb_set_configuration(LibUSB::Device::Handle dev, int configuration)
CODE:
    int rv = libusb_set_configuration(dev, configuration);
    handle_error(rv, "libusb_set_configuration");

void
libusb_claim_interface(LibUSB::Device::Handle dev, int interface_number)
CODE:
    int rv = libusb_claim_interface(dev, interface_number);
    handle_error(rv, "libusb_claim_interface");

void
libusb_release_interface(LibUSB::Device::Handle dev, int interface_number)
CODE:
    int rv = libusb_release_interface(dev, interface_number);
    handle_error(rv, "libusb_release_interface");

void
libusb_set_interface_alt_setting(LibUSB::Device::Handle dev, int interface_number, int alternate_setting)
CODE:
    int rv = libusb_set_interface_alt_setting(dev, interface_number, alternate_setting);
    handle_error(rv, "libusb_set_interface_alt_setting");

void
libusb_clear_halt(LibUSB::Device::Handle dev, unsigned endpoint)
CODE:
    int rv = libusb_clear_halt(dev, endpoint);
    handle_error(rv, "libusb_clear_halt");

void
libusb_reset_device(LibUSB::Device::Handle dev)
CODE:
    int rv = libusb_reset_device(dev);
    handle_error(rv, "libusb_reset_device");



void
DESTROY(LibUSB::Device::Handle handle)
CODE:
    libusb_close(handle);