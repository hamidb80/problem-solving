#define HID_INPUT_REPORT_BYTES       64              /* size of report in Bytes */
#define HID_OUTPUT_REPORT_BYTES      64              /* size of report in Bytes */
#define HID_FEATURE_REPORT_BYTES     64              /* size of report in Bytes */

#define WBVAL(x) (x & 0xFF),((x >> 8) & 0xFF)

#define USB_DEVICE_DESC_SIZE        (sizeof(USB_DEVICE_DESCRIPTOR))
#define USB_CONFIGUARTION_DESC_SIZE (sizeof(USB_CONFIGURATION_DESCRIPTOR))
#define USB_INTERFACE_DESC_SIZE     (sizeof(USB_INTERFACE_DESCRIPTOR))
#define USB_ENDPOINT_DESC_SIZE      (sizeof(USB_ENDPOINT_DESCRIPTOR))

#define HID_DESC_OFFSET              0x0012
#define HID_DESC_SIZE               (sizeof(HID_DESCRIPTOR))
#define HID_REPORT_DESC_SIZE        (sizeof(HID_ReportDescriptor1))
