/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "D:/Xilinx/git/mbo5_3_tech/MBO_5_3_FPGA_proj/MBO53/verilog/dac_2624.v";
static int ng1[] = {0, 0};
static unsigned int ng2[] = {0U, 0U};
static unsigned int ng3[] = {33U, 0U};
static int ng4[] = {1, 0};
static int ng5[] = {31, 0};
static int ng6[] = {2, 0};
static unsigned int ng7[] = {3U, 0U};
static int ng8[] = {23, 0};
static int ng9[] = {20, 0};
static int ng10[] = {19, 0};
static int ng11[] = {16, 0};
static int ng12[] = {15, 0};
static int ng13[] = {4, 0};



static void Cont_40_0(char *t0)
{
    char t5[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;
    unsigned int t25;
    unsigned int t26;
    char *t27;

LAB0:    t1 = (t0 + 4400U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(40, ng0);
    t2 = (t0 + 3000);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    memset(t5, 0, 8);
    t6 = (t5 + 4);
    t7 = (t4 + 4);
    t8 = *((unsigned int *)t4);
    t9 = (t8 >> 31);
    t10 = (t9 & 1);
    *((unsigned int *)t5) = t10;
    t11 = *((unsigned int *)t7);
    t12 = (t11 >> 31);
    t13 = (t12 & 1);
    *((unsigned int *)t6) = t13;
    t14 = (t0 + 5592);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    memset(t18, 0, 8);
    t19 = 1U;
    t20 = t19;
    t21 = (t5 + 4);
    t22 = *((unsigned int *)t5);
    t19 = (t19 & t22);
    t23 = *((unsigned int *)t21);
    t20 = (t20 & t23);
    t24 = (t18 + 4);
    t25 = *((unsigned int *)t18);
    *((unsigned int *)t18) = (t25 | t19);
    t26 = *((unsigned int *)t24);
    *((unsigned int *)t24) = (t26 | t20);
    xsi_driver_vfirst_trans(t14, 0, 0);
    t27 = (t0 + 5464);
    *((int *)t27) = 1;

LAB1:    return;
}

static void Cont_41_1(char *t0)
{
    char t3[8];
    char t4[8];
    char t18[8];
    char *t1;
    char *t2;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    char *t19;
    char *t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    char *t26;
    char *t27;
    char *t28;
    unsigned int t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    unsigned int t36;
    unsigned int t37;
    unsigned int t38;
    unsigned int t39;
    unsigned int t40;
    char *t41;
    char *t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;
    unsigned int t47;
    unsigned int t48;
    char *t49;
    unsigned int t50;
    unsigned int t51;
    char *t52;
    unsigned int t53;
    unsigned int t54;
    char *t55;

LAB0:    t1 = (t0 + 4648U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(41, ng0);
    t2 = (t0 + 3320);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB4;

LAB5:    if (*((unsigned int *)t7) != 0)
        goto LAB6;

LAB7:    t14 = (t4 + 4);
    t15 = *((unsigned int *)t4);
    t16 = *((unsigned int *)t14);
    t17 = (t15 || t16);
    if (t17 > 0)
        goto LAB8;

LAB9:    t37 = *((unsigned int *)t4);
    t38 = (~(t37));
    t39 = *((unsigned int *)t14);
    t40 = (t38 || t39);
    if (t40 > 0)
        goto LAB10;

LAB11:    if (*((unsigned int *)t14) > 0)
        goto LAB12;

LAB13:    if (*((unsigned int *)t4) > 0)
        goto LAB14;

LAB15:    memcpy(t3, t41, 8);

LAB16:    t42 = (t0 + 5656);
    t43 = (t42 + 56U);
    t44 = *((char **)t43);
    t45 = (t44 + 56U);
    t46 = *((char **)t45);
    memset(t46, 0, 8);
    t47 = 1U;
    t48 = t47;
    t49 = (t3 + 4);
    t50 = *((unsigned int *)t3);
    t47 = (t47 & t50);
    t51 = *((unsigned int *)t49);
    t48 = (t48 & t51);
    t52 = (t46 + 4);
    t53 = *((unsigned int *)t46);
    *((unsigned int *)t46) = (t53 | t47);
    t54 = *((unsigned int *)t52);
    *((unsigned int *)t52) = (t54 | t48);
    xsi_driver_vfirst_trans(t42, 0, 0);
    t55 = (t0 + 5480);
    *((int *)t55) = 1;

LAB1:    return;
LAB4:    *((unsigned int *)t4) = 1;
    goto LAB7;

LAB6:    t13 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t13) = 1;
    goto LAB7;

LAB8:    t19 = (t0 + 1320U);
    t20 = *((char **)t19);
    memset(t18, 0, 8);
    t19 = (t20 + 4);
    t21 = *((unsigned int *)t19);
    t22 = (~(t21));
    t23 = *((unsigned int *)t20);
    t24 = (t23 & t22);
    t25 = (t24 & 1U);
    if (t25 != 0)
        goto LAB20;

LAB18:    if (*((unsigned int *)t19) == 0)
        goto LAB17;

LAB19:    t26 = (t18 + 4);
    *((unsigned int *)t18) = 1;
    *((unsigned int *)t26) = 1;

LAB20:    t27 = (t18 + 4);
    t28 = (t20 + 4);
    t29 = *((unsigned int *)t20);
    t30 = (~(t29));
    *((unsigned int *)t18) = t30;
    *((unsigned int *)t27) = 0;
    if (*((unsigned int *)t28) != 0)
        goto LAB22;

LAB21:    t35 = *((unsigned int *)t18);
    *((unsigned int *)t18) = (t35 & 4294967295U);
    t36 = *((unsigned int *)t27);
    *((unsigned int *)t27) = (t36 & 4294967295U);
    goto LAB9;

LAB10:    t41 = ((char*)((ng1)));
    goto LAB11;

LAB12:    xsi_vlog_unsigned_bit_combine(t3, 32, t18, 32, t41, 32);
    goto LAB16;

LAB14:    memcpy(t3, t18, 8);
    goto LAB16;

LAB17:    *((unsigned int *)t18) = 1;
    goto LAB20;

LAB22:    t31 = *((unsigned int *)t18);
    t32 = *((unsigned int *)t28);
    *((unsigned int *)t18) = (t31 | t32);
    t33 = *((unsigned int *)t27);
    t34 = *((unsigned int *)t28);
    *((unsigned int *)t27) = (t33 | t34);
    goto LAB21;

}

static void Cont_42_2(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    unsigned int t10;
    unsigned int t11;
    char *t12;
    unsigned int t13;
    unsigned int t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    char *t18;

LAB0:    t1 = (t0 + 4896U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(42, ng0);
    t2 = (t0 + 3160);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 5720);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memset(t9, 0, 8);
    t10 = 1U;
    t11 = t10;
    t12 = (t4 + 4);
    t13 = *((unsigned int *)t4);
    t10 = (t10 & t13);
    t14 = *((unsigned int *)t12);
    t11 = (t11 & t14);
    t15 = (t9 + 4);
    t16 = *((unsigned int *)t9);
    *((unsigned int *)t9) = (t16 | t10);
    t17 = *((unsigned int *)t15);
    *((unsigned int *)t15) = (t17 | t11);
    xsi_driver_vfirst_trans(t5, 0, 0);
    t18 = (t0 + 5496);
    *((int *)t18) = 1;

LAB1:    return;
}

static void Always_44_3(char *t0)
{
    char t13[8];
    char t37[8];
    char t38[8];
    char t39[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t12;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    char *t35;
    char *t36;
    char *t40;
    char *t41;
    char *t42;
    char *t43;
    int t44;
    char *t45;
    int t46;
    int t47;
    char *t48;
    int t49;
    int t50;
    int t51;
    int t52;
    int t53;
    int t54;

LAB0:    t1 = (t0 + 5144U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(44, ng0);
    t2 = (t0 + 5512);
    *((int *)t2) = 1;
    t3 = (t0 + 5176);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(44, ng0);

LAB5:    xsi_set_current_line(46, ng0);
    t4 = (t0 + 1480U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(52, ng0);

LAB10:    xsi_set_current_line(53, ng0);
    t2 = (t0 + 1640U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB11;

LAB12:    xsi_set_current_line(60, ng0);

LAB27:    xsi_set_current_line(61, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3480);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 6, 0LL);

LAB13:
LAB8:    xsi_set_current_line(69, ng0);
    t2 = (t0 + 3480);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);

LAB28:    t5 = ((char*)((ng1)));
    t44 = xsi_vlog_unsigned_case_compare(t4, 6, t5, 32);
    if (t44 == 1)
        goto LAB29;

LAB30:    t2 = ((char*)((ng6)));
    t44 = xsi_vlog_unsigned_case_compare(t4, 6, t2, 32);
    if (t44 == 1)
        goto LAB31;

LAB32:
LAB33:    goto LAB2;

LAB6:    xsi_set_current_line(46, ng0);

LAB9:    xsi_set_current_line(47, ng0);
    t11 = ((char*)((ng2)));
    t12 = (t0 + 3480);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 6, 0LL);
    goto LAB8;

LAB11:    xsi_set_current_line(53, ng0);

LAB14:    xsi_set_current_line(54, ng0);
    t4 = (t0 + 3480);
    t5 = (t4 + 56U);
    t11 = *((char **)t5);
    t12 = ((char*)((ng3)));
    memset(t13, 0, 8);
    t14 = (t11 + 4);
    t15 = (t12 + 4);
    t16 = *((unsigned int *)t11);
    t17 = *((unsigned int *)t12);
    t18 = (t16 ^ t17);
    t19 = *((unsigned int *)t14);
    t20 = *((unsigned int *)t15);
    t21 = (t19 ^ t20);
    t22 = (t18 | t21);
    t23 = *((unsigned int *)t14);
    t24 = *((unsigned int *)t15);
    t25 = (t23 | t24);
    t26 = (~(t25));
    t27 = (t22 & t26);
    if (t27 != 0)
        goto LAB18;

LAB15:    if (t25 != 0)
        goto LAB17;

LAB16:    *((unsigned int *)t13) = 1;

LAB18:    t29 = (t13 + 4);
    t30 = *((unsigned int *)t29);
    t31 = (~(t30));
    t32 = *((unsigned int *)t13);
    t33 = (t32 & t31);
    t34 = (t33 != 0);
    if (t34 > 0)
        goto LAB19;

LAB20:    xsi_set_current_line(55, ng0);
    t2 = (t0 + 3480);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = ((char*)((ng4)));
    memset(t13, 0, 8);
    xsi_vlog_unsigned_add(t13, 32, t4, 6, t5, 32);
    t11 = (t0 + 3480);
    xsi_vlogvar_wait_assign_value(t11, t13, 0, 0, 6, 0LL);

LAB21:    xsi_set_current_line(57, ng0);
    t2 = (t0 + 3320);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 4);
    t6 = *((unsigned int *)t5);
    t7 = (~(t6));
    t8 = *((unsigned int *)t4);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB22;

LAB23:
LAB24:    goto LAB13;

LAB17:    t28 = (t13 + 4);
    *((unsigned int *)t13) = 1;
    *((unsigned int *)t28) = 1;
    goto LAB18;

LAB19:    xsi_set_current_line(54, ng0);
    t35 = ((char*)((ng1)));
    t36 = (t0 + 3480);
    xsi_vlogvar_wait_assign_value(t36, t35, 0, 0, 6, 0LL);
    goto LAB21;

LAB22:    xsi_set_current_line(57, ng0);
    t11 = (t0 + 3000);
    t12 = (t11 + 56U);
    t14 = *((char **)t12);
    memset(t13, 0, 8);
    t15 = (t13 + 4);
    t28 = (t14 + 4);
    t16 = *((unsigned int *)t14);
    t17 = (t16 >> 0);
    *((unsigned int *)t13) = t17;
    t18 = *((unsigned int *)t28);
    t19 = (t18 >> 0);
    *((unsigned int *)t15) = t19;
    t20 = *((unsigned int *)t13);
    *((unsigned int *)t13) = (t20 & 2147483647U);
    t21 = *((unsigned int *)t15);
    *((unsigned int *)t15) = (t21 & 2147483647U);
    t29 = (t0 + 3000);
    t35 = (t0 + 3000);
    t36 = (t35 + 72U);
    t40 = *((char **)t36);
    t41 = ((char*)((ng5)));
    t42 = ((char*)((ng4)));
    xsi_vlog_convert_partindices(t37, t38, t39, ((int*)(t40)), 2, t41, 32, 1, t42, 32, 1);
    t43 = (t37 + 4);
    t22 = *((unsigned int *)t43);
    t44 = (!(t22));
    t45 = (t38 + 4);
    t23 = *((unsigned int *)t45);
    t46 = (!(t23));
    t47 = (t44 && t46);
    t48 = (t39 + 4);
    t24 = *((unsigned int *)t48);
    t49 = (!(t24));
    t50 = (t47 && t49);
    if (t50 == 1)
        goto LAB25;

LAB26:    goto LAB24;

LAB25:    t25 = *((unsigned int *)t39);
    t51 = (t25 + 0);
    t26 = *((unsigned int *)t37);
    t27 = *((unsigned int *)t38);
    t52 = (t26 - t27);
    t53 = (t52 + 1);
    xsi_vlogvar_wait_assign_value(t29, t13, t51, *((unsigned int *)t38), t53, 0LL);
    goto LAB26;

LAB29:    xsi_set_current_line(71, ng0);

LAB34:    xsi_set_current_line(72, ng0);
    t11 = ((char*)((ng4)));
    t12 = (t0 + 3160);
    xsi_vlogvar_wait_assign_value(t12, t11, 0, 0, 1, 0LL);
    xsi_set_current_line(73, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3320);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(74, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 3000);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 32, 0LL);
    goto LAB33;

LAB31:    xsi_set_current_line(76, ng0);

LAB35:    xsi_set_current_line(76, ng0);
    t3 = ((char*)((ng7)));
    t5 = (t0 + 3000);
    t11 = (t0 + 3000);
    t12 = (t11 + 72U);
    t14 = *((char **)t12);
    t15 = ((char*)((ng8)));
    t28 = ((char*)((ng9)));
    xsi_vlog_convert_partindices(t13, t37, t38, ((int*)(t14)), 2, t15, 32, 1, t28, 32, 1);
    t29 = (t13 + 4);
    t6 = *((unsigned int *)t29);
    t46 = (!(t6));
    t35 = (t37 + 4);
    t7 = *((unsigned int *)t35);
    t47 = (!(t7));
    t49 = (t46 && t47);
    t36 = (t38 + 4);
    t8 = *((unsigned int *)t36);
    t50 = (!(t8));
    t51 = (t49 && t50);
    if (t51 == 1)
        goto LAB36;

LAB37:    xsi_set_current_line(77, ng0);
    t2 = ((char*)((ng2)));
    t3 = (t0 + 3000);
    t5 = (t0 + 3000);
    t11 = (t5 + 72U);
    t12 = *((char **)t11);
    t14 = ((char*)((ng10)));
    t15 = ((char*)((ng11)));
    xsi_vlog_convert_partindices(t13, t37, t38, ((int*)(t12)), 2, t14, 32, 1, t15, 32, 1);
    t28 = (t13 + 4);
    t6 = *((unsigned int *)t28);
    t44 = (!(t6));
    t29 = (t37 + 4);
    t7 = *((unsigned int *)t29);
    t46 = (!(t7));
    t47 = (t44 && t46);
    t35 = (t38 + 4);
    t8 = *((unsigned int *)t35);
    t49 = (!(t8));
    t50 = (t47 && t49);
    if (t50 == 1)
        goto LAB38;

LAB39:    xsi_set_current_line(78, ng0);
    t2 = (t0 + 1800U);
    t3 = *((char **)t2);
    t2 = (t0 + 3000);
    t5 = (t0 + 3000);
    t11 = (t5 + 72U);
    t12 = *((char **)t11);
    t14 = ((char*)((ng12)));
    t15 = ((char*)((ng13)));
    xsi_vlog_convert_partindices(t13, t37, t38, ((int*)(t12)), 2, t14, 32, 1, t15, 32, 1);
    t28 = (t13 + 4);
    t6 = *((unsigned int *)t28);
    t44 = (!(t6));
    t29 = (t37 + 4);
    t7 = *((unsigned int *)t29);
    t46 = (!(t7));
    t47 = (t44 && t46);
    t35 = (t38 + 4);
    t8 = *((unsigned int *)t35);
    t49 = (!(t8));
    t50 = (t47 && t49);
    if (t50 == 1)
        goto LAB40;

LAB41:    xsi_set_current_line(79, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 3160);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    xsi_set_current_line(80, ng0);
    t2 = ((char*)((ng4)));
    t3 = (t0 + 3320);
    xsi_vlogvar_wait_assign_value(t3, t2, 0, 0, 1, 0LL);
    goto LAB33;

LAB36:    t9 = *((unsigned int *)t38);
    t52 = (t9 + 0);
    t10 = *((unsigned int *)t13);
    t16 = *((unsigned int *)t37);
    t53 = (t10 - t16);
    t54 = (t53 + 1);
    xsi_vlogvar_wait_assign_value(t5, t3, t52, *((unsigned int *)t37), t54, 0LL);
    goto LAB37;

LAB38:    t9 = *((unsigned int *)t38);
    t51 = (t9 + 0);
    t10 = *((unsigned int *)t13);
    t16 = *((unsigned int *)t37);
    t52 = (t10 - t16);
    t53 = (t52 + 1);
    xsi_vlogvar_wait_assign_value(t3, t2, t51, *((unsigned int *)t37), t53, 0LL);
    goto LAB39;

LAB40:    t9 = *((unsigned int *)t38);
    t51 = (t9 + 0);
    t10 = *((unsigned int *)t13);
    t16 = *((unsigned int *)t37);
    t52 = (t10 - t16);
    t53 = (t52 + 1);
    xsi_vlogvar_wait_assign_value(t2, t3, t51, *((unsigned int *)t37), t53, 0LL);
    goto LAB41;

}


extern void work_m_00000000001054871120_0682024583_init()
{
	static char *pe[] = {(void *)Cont_40_0,(void *)Cont_41_1,(void *)Cont_42_2,(void *)Always_44_3};
	xsi_register_didat("work_m_00000000001054871120_0682024583", "isim/dac_2624_tb_isim_beh.exe.sim/work/m_00000000001054871120_0682024583.didat");
	xsi_register_executes(pe);
}
