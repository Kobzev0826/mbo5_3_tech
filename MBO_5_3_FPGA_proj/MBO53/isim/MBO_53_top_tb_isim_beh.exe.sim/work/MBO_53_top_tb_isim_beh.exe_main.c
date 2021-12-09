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

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    unisims_ver_m_00000000001946988858_2297623829_init();
    unisims_ver_m_00000000003266096158_2593380106_init();
    unisims_ver_m_00000000002399568039_2282143210_init();
    unisims_ver_m_00000000000740258969_3897995058_init();
    unisims_ver_m_00000000000740258969_1625843133_init();
    unisims_ver_m_00000000003131622635_0225263307_init();
    unisims_ver_m_00000000002922998384_0744449446_init();
    work_m_00000000003219443879_3690717137_init();
    unisims_ver_m_00000000002922998384_0007661977_init();
    work_m_00000000004193112729_4110091611_init();
    work_m_00000000003587703255_2512656963_init();
    xilinxcorelib_ver_m_00000000000200492576_2632141972_init();
    xilinxcorelib_ver_m_00000000000401602519_3266681940_init();
    xilinxcorelib_ver_m_00000000001159543956_2643559099_init();
    xilinxcorelib_ver_m_00000000001291582275_1506151403_init();
    work_m_00000000002998642966_3660464351_init();
    work_m_00000000000699503156_1776481059_init();
    work_m_00000000003890517729_3118602921_init();
    work_m_00000000004134447467_2073120511_init();


    xsi_register_tops("work_m_00000000003890517729_3118602921");
    xsi_register_tops("work_m_00000000004134447467_2073120511");


    return xsi_run_simulation(argc, argv);

}
