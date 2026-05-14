/* COE838 - System-on-Chip
 * Lab 4 - Custom IP for HPS/FPGA Systems
 * ALU version main.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "hwlib.h"
#include "socal/socal.h"
#include "socal/hps.h"
#include "socal/alt_gpio.h"
#include "hps_0.h"

#define LW_SIZE            0x00200000
#define LWHPS2FPGA_BASE    0xff200000

/* ALU control register offsets */
#define ALU_CTRL_START     0
#define ALU_CTRL_RESET     1
#define ALU_CTRL_DONE      2

/* ALU data register offsets */
#define ALU_DATA_RESULT    0   /* read result */
#define ALU_DATA_IN1       0   /* write A */
#define ALU_DATA_IN2       1   /* write B */
#define ALU_DATA_CFG       2   /* write/read config */
#define ALU_DATA_IN1_RD    1   /* optional readback */
#define ALU_DATA_IN2_RD    2   /* optional readback */
#define ALU_DATA_CFG_RD    3   /* config readback if implemented that way */

/* Config bits
 * bit 0 = alu_op     : 1 = add, 0 = subtract
 * bit 1 = shift_en   : 1 = enable shift on B
 * bit 2 = shift_dir  : 0 = left, 1 = right
 * bits 6:3 = shift_amt
 */
#define CFG_ALU_OP_ADD         (1u << 0)
#define CFG_SHIFT_EN           (1u << 1)
#define CFG_SHIFT_DIR_RIGHT    (1u << 2)

volatile uint32_t *alu_control = NULL;
volatile uint32_t *alu_data = NULL;

int success = 0;
int total = 0;

static uint32_t build_cfg(uint32_t add_not_sub, uint32_t shift_en, uint32_t shift_dir, uint32_t shift_amt)
{
    uint32_t cfg = 0;

    if (add_not_sub) {
        cfg |= CFG_ALU_OP_ADD;
    }
    if (shift_en) {
        cfg |= CFG_SHIFT_EN;
    }
    if (shift_dir) {
        cfg |= CFG_SHIFT_DIR_RIGHT;
    }

    cfg |= ((shift_amt & 0xF) << 3);
    return cfg;
}

static uint32_t expected_result(uint32_t a, uint32_t b, uint32_t cfg)
{
    uint32_t add_not_sub = (cfg >> 0) & 0x1;
    uint32_t shift_en    = (cfg >> 1) & 0x1;
    uint32_t shift_dir   = (cfg >> 2) & 0x1;
    uint32_t shift_amt   = (cfg >> 3) & 0xF;
    uint32_t b_mod       = b & 0xFFFF;
    uint32_t a_mod       = a & 0xFFFF;
    uint32_t result;

    if (shift_en) {
        if (shift_dir == 0) {
            b_mod = (b_mod << shift_amt) & 0xFFFF;
        } else {
            b_mod = (b_mod >> shift_amt) & 0xFFFF;
        }
    }

    if (add_not_sub) {
        result = (a_mod + b_mod) & 0xFFFF;
    } else {
        result = (a_mod - b_mod) & 0xFFFF;
    }

    return result;
}

static void reset_system(void)
{
    alt_write_word(alu_control + ALU_CTRL_RESET, 0x1);

    while (!(alt_read_word(alu_control + ALU_CTRL_RESET) & 0x1)) {
    }

    printf("Reset done. Deasserting signal\n");

    while ((alt_read_word(alu_control + ALU_CTRL_RESET) & 0x1)) {
    }
}

static void run_alu(uint32_t a, uint32_t b, uint32_t cfg)
{
    alt_write_word(alu_data + ALU_DATA_IN1, a);
    alt_write_word(alu_data + ALU_DATA_IN2, b);
    alt_write_word(alu_data + ALU_DATA_CFG, cfg);

    alt_write_word(alu_control + ALU_CTRL_START, 0x1);

    while (!(alt_read_word(alu_control + ALU_CTRL_START) & 0x1)) {
    }

    printf("Start successful\n");
}

static void read_and_check_output(const char *label)
{
    uint32_t result;
    uint32_t a_rd;
    uint32_t b_rd;
    uint32_t cfg_rd;
    uint32_t expected;
    uint32_t add_not_sub;
    uint32_t shift_en;
    uint32_t shift_dir;
    uint32_t shift_amt;

    printf("Waiting for done\n");
    while (!(alt_read_word(alu_control + ALU_CTRL_DONE) & 0x1)) {
    }

    printf("Operation done\n");

    result = alt_read_word(alu_data + ALU_DATA_RESULT);
    a_rd   = alt_read_word(alu_data + ALU_DATA_IN1_RD);
    b_rd   = alt_read_word(alu_data + ALU_DATA_IN2_RD);
    cfg_rd = alt_read_word(alu_data + ALU_DATA_CFG_RD);

    expected = expected_result(a_rd, b_rd, cfg_rd);

    add_not_sub = (cfg_rd >> 0) & 0x1;
    shift_en    = (cfg_rd >> 1) & 0x1;
    shift_dir   = (cfg_rd >> 2) & 0x1;
    shift_amt   = (cfg_rd >> 3) & 0xF;

    printf("%s\n", label);
    printf("A = 0x%08x, B = 0x%08x, CFG = 0x%08x\n", a_rd, b_rd, cfg_rd);
    printf("op=%s, shift_en=%u, shift_dir=%s, shift_amt=%u\n",
           add_not_sub ? "ADD" : "SUB",
           shift_en,
           shift_dir ? "RIGHT" : "LEFT",
           shift_amt);
    printf("Result = 0x%08x, Expected = 0x%08x\n", result, expected);

    if ((result & 0xFFFF) == (expected & 0xFFFF)) {
        printf("[SUCCESSFUL]\n");
        success++;
    } else {
        printf("[FAILED]\n");
    }

    total++;
    printf("------------------------------------------------\n");
}

int main(int argc, char **argv)
{
    int fd;
    void *virtual_base;

    success = 0;
    total = 0;

    if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
        printf("ERROR: could not open /dev/mem\n");
        return 1;
    }

    virtual_base = mmap(NULL, LW_SIZE, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, LWHPS2FPGA_BASE);

    if (virtual_base == MAP_FAILED) {
        printf("ERROR: mmap() failed\n");
        close(fd);
        return 1;
    }

    alu_control = (volatile uint32_t *)((uint8_t *)virtual_base + ALU_CONTROL_0_BASE);
    alu_data    = (volatile uint32_t *)((uint8_t *)virtual_base + ALU_DATA_0_BASE);

    printf("------> Finished initializing HPS/FPGA system <-------\n");
    printf("ALU_CONTROL_0_BASE = 0x%08x\n", ALU_CONTROL_0_BASE);
    printf("ALU_DATA_0_BASE    = 0x%08x\n", ALU_DATA_0_BASE);
    printf("------------------------------------------------\n");

    reset_system();
    run_alu(10, 3, build_cfg(1, 0, 0, 0));
    read_and_check_output("Test 1: 10 + 3");

    reset_system();
    run_alu(10, 3, build_cfg(0, 0, 0, 0));
    read_and_check_output("Test 2: 10 - 3");

    reset_system();
    run_alu(10, 3, build_cfg(1, 1, 0, 2));
    read_and_check_output("Test 3: 10 + (3 << 2)");

    reset_system();
    run_alu(20, 8, build_cfg(0, 1, 1, 1));
    read_and_check_output("Test 4: 20 - (8 >> 1)");

    reset_system();
    run_alu(25, 6, build_cfg(1, 1, 1, 1));
    read_and_check_output("Test 5: 25 + (6 >> 1)");

    reset_system();
    run_alu(40, 5, build_cfg(0, 1, 0, 3));
    read_and_check_output("Test 6: 40 - (5 << 3)");

    printf("[TEST PASSED] %d/%d\n", success, total);

    if (munmap(virtual_base, LW_SIZE) != 0) {
        printf("ERROR: munmap() failed\n");
        close(fd);
        return 1;
    }

    close(fd);
    return 0;
}
