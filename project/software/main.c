#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

/* LWH2F bridge span */
#define HW_REGS_BASE   ALT_STM_OFST
#define HW_REGS_SPAN   0x04000000
#define HW_REGS_MASK   (HW_REGS_SPAN - 1)

/* Control slave offsets */
#define MD5_CTRL_START   0x00
#define MD5_CTRL_RESET   0x04
#define MD5_CTRL_DONE    0x08

/* Data slave offsets */
#define MD5_DATA_WRITEDATA  0x00
#define MD5_DATA_WRITEADDR  0x04
#define MD5_DATA_WR         0x08
#define MD5_DATA_READADDR   0x0C
#define MD5_DATA_READDATA   0x10

static uint32_t make_writeaddr(uint32_t engine, uint32_t word_index)
{
    uint32_t unit = engine / 2;
    uint32_t subengine = engine % 2;
    return (unit << 5) | (subengine << 4) | word_index;
}

static uint32_t make_readaddr(uint32_t engine, uint32_t digest_word)
{
    return (engine << 2) | digest_word;
}

static void pulse_reg(void *base, uint32_t offset, uint32_t value)
{
    alt_write_word((uint8_t *)base + offset, value);
    alt_write_word((uint8_t *)base + offset, 0);
}

static void reset_engine(void *ctrl_base, uint32_t engine)
{
    uint32_t bitmask = (1u << engine);
    pulse_reg(ctrl_base, MD5_CTRL_RESET, bitmask);
}

static void start_engine(void *ctrl_base, uint32_t engine)
{
    uint32_t bitmask = (1u << engine);
    pulse_reg(ctrl_base, MD5_CTRL_START, bitmask);
}

static void load_message(void *data_base, uint32_t engine, const uint32_t msg[16])
{
    int i;
    for (i = 0; i < 16; i++) {
        alt_write_word((uint8_t *)data_base + MD5_DATA_WRITEDATA, msg[i]);
        alt_write_word((uint8_t *)data_base + MD5_DATA_WRITEADDR, make_writeaddr(engine, i));
        alt_write_word((uint8_t *)data_base + MD5_DATA_WR, 1);
        alt_write_word((uint8_t *)data_base + MD5_DATA_WR, 0);
    }
}

static void wait_done(void *ctrl_base, uint32_t engine)
{
    uint32_t done_val;
    do {
        done_val = alt_read_word((uint8_t *)ctrl_base + MD5_CTRL_DONE);
    } while ((done_val & (1u << engine)) == 0);
}

static void read_digest(void *data_base, uint32_t engine, uint32_t digest[4])
{
    int i;
    for (i = 0; i < 4; i++) {
        alt_write_word((uint8_t *)data_base + MD5_DATA_READADDR, make_readaddr(engine, i));
        digest[i] = alt_read_word((uint8_t *)data_base + MD5_DATA_READDATA);
    }
}

int main(void)
{
    int fd;
    void *virtual_base;
    void *ctrl_base;
    void *data_base;

    uint32_t engine = 0;
    uint32_t message[16];
    uint32_t digest[4];
    int i;

    /* Simple test message: 16 x 32-bit words */
    for (i = 0; i < 16; i++) {
        message[i] = (uint32_t)i;
    }

    printf("Opening /dev/mem...\n");
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        printf("ERROR: could not open /dev/mem\n");
        return 1;
    }

    printf("Mapping lightweight bridge...\n");
    virtual_base = mmap(NULL, HW_REGS_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, HW_REGS_BASE);
    if (virtual_base == MAP_FAILED) {
        printf("ERROR: mmap() failed\n");
        close(fd);
        return 1;
    }

    ctrl_base = (uint8_t *)virtual_base + ((unsigned long)(HPS_0_ARM_A9_0_MD5_CONTROL_SLAVE_0_BASE) & HW_REGS_MASK);
    data_base = (uint8_t *)virtual_base + ((unsigned long)(HPS_0_ARM_A9_0_MD5_DATA_SLAVE_0_BASE) & HW_REGS_MASK);

    printf("---- MD5 smoke test: engine %u ----\n", engine);

    printf("Resetting engine...\n");
    reset_engine(ctrl_base, engine);

    printf("Loading 16 message words...\n");
    load_message(data_base, engine, message);

    printf("Starting engine...\n");
    start_engine(ctrl_base, engine);

    printf("Waiting for done...\n");
    wait_done(ctrl_base, engine);

    printf("Reading digest...\n");
    read_digest(data_base, engine, digest);

    printf("Digest words:\n");
    printf("D0 = 0x%08x\n", digest[0]);
    printf("D1 = 0x%08x\n", digest[1]);
    printf("D2 = 0x%08x\n", digest[2]);
    printf("D3 = 0x%08x\n", digest[3]);

    if (munmap(virtual_base, HW_REGS_SPAN) != 0) {
        printf("WARNING: munmap() failed\n");
    }

    close(fd);
    return 0;
}
