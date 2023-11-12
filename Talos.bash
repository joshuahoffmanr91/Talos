#!/bin/bash
# 
#    ____________________________________________________________________________________________________
#   |* ___________________________________________GPL-3_Licence________________________________________ *|
#   | /                                                                                                \ |
#   | |         This program is free software: you can redistribute it and/or modify                   | |
#   | |         it under the terms of the GNU General Public License as published by                   | |
#   | |         the Free Software Foundation, either version 3 of the License, or                      | |
#   | |         (at your option) any later version.                                                    | |
#   | |                                                                                                | |
#   | |         This program is distributed in the hope that it will be useful,                        | |
#   | |         but WITHOUT ANY WARRANTY; without even the implied warranty of                         | |
#   | |         MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                          | |
#   | |         GNU General Public License for more details.                                           | |
#   | |                                                                                                | |
#   | |         You should have received a copy of the GNU General Public License                      | |
#   | |         along with this program.  If not, see <http://www.gnu.org/licenses/>.                  | |
#   | |                                                                                                | |
#   | \________________________________________________________________________________________________/ |
#   |* ________________________________________Talos-v3.0_6/7/2019_____________________________________ *|
#   | /                                                                                                \ |
#   | |                         Script to check hardware health and system stats                       | |
#   | |                          Supported server types : SV-15 | SV-17 | SV-19                        | |
#   | |                                  Supported NOS versions: 11.5.7                                | |
#   | |                                    Written by: Joshua Hoffman                                  | |
#   | |                                    josh.ray.hoffman@gmail.com                                  | |
#   | |                                                                                                | |
#   | |                                         Byte size: 85037                                       | |
#   | |           Checksum: e4833673cf0b5e123ddef4893cf2f38f File name: Talos_v30_290c3.bash           | |
#   | \________________________________________________________________________________________________/ |
#   |* _______________________________________Executable_functions_____________________________________ *|
#   | /                                                                                                \ |
#   | |      1 - MAIN - Sets the formatting variables and contains the verification functions          | |
#   | |      2 - VERIF_USR - Checks to see if the current user is root                                 | |
#   | |      3 - VERIF_SIZ - Checks to ensure the script is the correct size                           | |
#   | |      3 - VERIF_MD5 - Checks the integreity of the script before execution                      | |
#   | |      4 - SETUP_DEP - Checks for needed packages and installs if missing                        | |
#   | |      5 - SETUP_FIL - Sets up the directory tree and generates/downloads required files         | |
#   | |      6 - SETUP_VAR - Sets the variables used in HDD and NET tests                              | |
#   | |      7 - SETUP_LOG - Generates/consolidates various logs and backs up to a remote server       | |
#   | |      8 - CHECK_NOS - Checks the status of NOS                                                  | |
#   | |      9 - CHECK_SYS - Checks general system parameters                                          | |
#   | |     10 - CHECK_RAD - Checks the status/health of the raid array                                | |
#   | |     11 - CHECK_COM - Checks to see if expected components are detected by the OS               | |
#   | |     12 - CHECK_NET - Checks general network settings                                           | |
#   | |     13 - CHECK_CPU - Checks the status of the CPU                                              | |
#   | |     14 - CHECK_VID - Checks the status of the HD-SDI card                                      | |
#   | |     15 - CHECK_CON - Checks the storage partition for content information                      | |
#   | |     16 - CHECK_STO - Checks the status of the system partitions/drive configuration            | |
#   | |     17 - CHECK_RAM - Checks the status/configuration of system memory                          | |
#   | |     18 - CHECK_TMP - Checks the temperature of various hardware components                     | |
#   | |     19 - CHECK_AWS - Checks Whale remote support status and tests AWS speedtest                | |
#   | |     20 - CHECK_NET_1 - Checks the configuration of the first NIC and runs a LAN speedtest      | |
#   | |     21 - CHECK_NET_2 - Same as CHECK_NET_1 for second interface                                | |
#   | |     22 - CHECK_NET_3 - Same as CHECK_NET_1 for third interface                                 | |
#   | |     23 - CHECK_HDD_1 - Checks the health of the first storage device and runs a benchmark      | |
#   | |     24 - CHECK_HDD_2 - Same as CHECK_HDD_1 for second storage device                           | |
#   | |     25 - CHECK_HDD_3 - Same as CHECK_HDD_1 for third storage device                            | |
#   | |     26 - CHECK_SAT_1 - Checks the status of the first satellite interface and last known loc   | |
#   | |     27 - CHECK_SAT_2 - Same as CHECK_SAT_1 for second satellite interface                      | |
#   | |     28 - CHECK_SAT_3 - Same as CHECK_SAT_1 for third satellite interface                       | |
#   | |     29 - CHECK_LOG - Checks the dmesg and tiger logs and lists the number and level of error   | |
#   | |     30 - CHECK_STR - Stresses the CPU and checks memory integrity                              | |
#   | |     31 - CHECK_CLN - Deletion/termination of files/processes, must be last function call       | |
#   | |                                                                                                | |
#   | \________________________________________________________________________________________________/ |
#   |* _______________________________________________Index____________________________________________ *|
#   | /                                                                                                \ |
#   | |                                                                                                | |
#   | |                                                                                                | |
#   | |        MAIN_                                                                                   | |
#   | |             \                                                                                  | |
#   | |              CDIR                                                                              | |
#   | |              CTIM                                                                              | |
#   | |              CDAT                                                                              | |
#   | |              FPTH                                                                              | |
#   | |              LPTH                                                                              | |
#   | |              NOSS                                                                              | |
#   | |              NOSN                                                                              | |
#   | |              SLOT                                                                              | |
#   | |              LINS                                                                              | |
#   | |              NAME                                                                              | |
#   | |              TIME                                                                              | |
#   | |              SLNU                                                                              | |
#   | |              DATE                                                                              | |
#   | |              REDD                                                                              | |
#   | |              GREE                                                                              | |
#   | |              BLUE                                                                              | |
#   | |              NONE                                                                              | |
#   | |             /                                                                                  | |
#   | |       MAIN-[                                                                                   | |
#   | |             \                                                                                  | |
#   | |              \_____VERIF_USR                                                                   | |
#   | |              /                                                                                 | |
#   | |             /                                                                                  | |
#   | |       MAIN-[                                                                                   | |
#   | |             \                                                                                  | |
#   | |              \_____VERIF_SIZ                                                                   | |
#   | |              /              \                                                                  | |
#   | |             /                EXPT                                                              | |
#   | |       MAIN-[                 CURR                                                              | |
#   | |             \                                                                                  | |
#   | |              \_____VERIF_MD5                                                                   | |
#   | |              /              \                                                                  | |
#   | |             /                HARD                                                              | |
#   | |       MAIN-[                 SOFT                                                              | |
#   | |             \                                                                                  | |
#   | |              \___________                                                                      | |
#   | |                          \                                                                     | |
#   | |                           \                                                                    | |
#   | |                            \_TALOS__                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_SETUP_DEP_                                             | |
#   | |                                       /           \                                            | |
#   | |                                      /             CHKDE                                       | |
#   | |                                     /                                                          | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_SETUP_FIL                                              | |
#   | |                                       /                                                        | |
#   | |                                      /                                                         | |
#   | |                                     /                                                          | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_SETUP_VAR_                                             | |
#   | |                                       /           \                                            | |
#   | |                                      /             HDNUM_1                                     | |
#   | |                                     /              HDNUM_2                                     | |
#   | |                                    |               HDNUM_3                                     | |
#   | |                                    |               HDNUM_S                                     | |
#   | |                                    |               NETIF_1                                     | |
#   | |                              TALOS-[               NETIF_2                                     | |
#   | |                                    |               NETIF_3                                     | |
#   | |                                    |               SATNM_1                                     | |
#   | |                                    |               SATNM_2                                     | |
#   | |                                     \              SATNM_3                                     | |
#   | |                                      \                                                         | |
#   | |                                       \_SETUP_LOG_                                             | |
#   | |                                       /           \                                            | |
#   | |                                      /             LODMS                                       | |
#   | |                                     /              LOGST                                       | |
#   | |                              TALOS-[               LOHDW                                       | |
#   | |                                     \              LONET                                       | |
#   | |                                      \             LOMIS                                       | |
#   | |                                       \_CLN_STATS_                                             | |
#   | |                                       /           \                                            | |
#   | |                                      /             YESCH                                       | |
#   | |                                     /              CLNHX                                       | |
#   | |                                    |               CLNTM                                       | |
#   | |                                    |               CLNPK                                       | |
#   | |                              TALOS-[               TOERR                                       | |
#   | |                                    |               TOPKG                                       | |
#   | |                                    |               CHKMD                                       | |
#   | |                                     \              CHKMD                                       | |
#   | |                                      \                                                         | |
#   | |                                       \_DSK_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_DSK_1                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               OPTR_1                   | |
#   | |                                                      /                OPTS_1                   | |
#   | |                                                     /                 OPTN_1                   | |
#   | |                                                    /                  OPTC_1                   | |
#   | |                                         DSK_STATS-[                   OPTO_1                   | |
#   | |                                                    \                  OPTI_1                   | |
#   | |                                                     \                 OPTL_1                   | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_DSK_2                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               OPTR_2                   | |
#   | |                                                      /                OPTS_2                   | |
#   | |                                                     /                 OPTN_2                   | |
#   | |                                                    /                  OPTC_2                   | |
#   | |                                         DSK_STATS-[                   OPTO_2                   | |
#   | |                                                    \                  OPTI_2                   | |
#   | |                                                     \                 OPTL_2                   | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_DSK_3                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               OPTR_3                   | |
#   | |                                                      /                OPTS_3                   | |
#   | |                                                     /                 OPTN_3                   | |
#   | |                                        ____________/                  OPTC_3                   | |
#   | |                                       /                               OPTO_3                   | |
#   | |                                      /                                OPTI_3                   | |
#   | |                                     /                                                          | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_NET_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_NET_1                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               ETHLD_1                  | |
#   | |                                                      /                ETHIP_1                  | |
#   | |                                                     /                 ETHNM_1                  | |
#   | |                                                    /                  ETHMA_1                  | |
#   | |                                         NET_STATS-[                   ETHNA_1                  | |
#   | |                                                    \                  ETHSP_1                  | |
#   | |                                                     \                 ETHTF_1                  | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_NET_2                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               ETHLD_2                  | |
#   | |                                                      /                ETHIP_2                  | |
#   | |                                                     /                 ETHNM_2                  | |
#   | |                                                    /                  ETHMA_2                  | |
#   | |                                         NET_STATS-[                   ETHNA_2                  | |
#   | |                                                    \                  ETHSP_2                  | |
#   | |                                                     \                 ETHTF_2                  | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |___CHECK_NET_3                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               ETHLD_3                  | |
#   | |                                                      /                ETHIP_3                  | |
#   | |                                                     /                 ETHNM_3                  | |
#   | |                                        ____________/                  ETHMA_3                  | |
#   | |                                       /                               ETHNA_3                  | |
#   | |                                      /                                ETHSP_3                  | |
#   | |                                     /                                 ETHTF_3                  | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_SAT_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_SAT_1                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               SATNM_1                  | |
#   | |                                                      /                SATSG_1                  | |
#   | |                                                     /                 SATDT_1                  | |
#   | |                                                    /                  SATMA_1                  | |
#   | |                                         SAT_STATS-[                   SATEB_1                  | |
#   | |                                                    \                  SATLK_1                  | |
#   | |                                                     \                 SATRE_1                  | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_SAT_2                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               SATNM_2                  | |
#   | |                                                      /                SATSG_2                  | |
#   | |                                                     /                 SATDT_2                  | |
#   | |                                                    /                  SATMA_2                  | |
#   | |                                         SAT_STATS-[                   SATEB_2                  | |
#   | |                                                    \                  SATLK_2                  | |
#   | |                                                     \                 SATRE_2                  | |
#   | |                                                      \                                         | |
#   | |                                                       \                                        | |
#   | |                                                       |                                        | |
#   | |                                                       |___CHECK_SAT_3                          | |
#   | |                                                       |              \                         | |
#   | |                                                       /               SATNM_3                  | |
#   | |                                                      /                SATSG_3                  | |
#   | |                                                     /                 SATDT_3                  | |
#   | |                                        ____________/                  SATMA_3                  | |
#   | |                                       /                               SATEB_3                  | |
#   | |                                      /                                SATLK_3                  | |
#   | |                                     /                                 SATRE_3                  | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_NOS_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_NOS__                          | |
#   | |                                                      |               \                         | |
#   | |                                                      /                NOSOS                    | |
#   | |                                                     /                 NOSSV                    | |
#   | |                                        ____________/                  NOSPV                    | |
#   | |                                       /                               NOSCL                    | |
#   | |                                      /                                NOSAV                    | |
#   | |                                     /                                 NOSST                    | |
#   | |                              TALOS-[                                                           | |
#   | |                                     \                                                          | |
#   | |                                      \                                                         | |
#   | |                                       \_SYS_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_SYS__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 SYSTI                    | |
#   | |                                        ____________/                  SYSUT                    | |
#   | |                                       /                               SYSRS                    | |
#   | |                                      /                                SYSDI                    | |
#   | |                                     /                                 SYSKV                    | |
#   | |                              TALOS-[                                  SYSKR                    | |
#   | |                                     \                                 SYSIM                    | |
#   | |                                      \                                SUSUP                    | |
#   | |                                       \_LOG_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_LOG__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 SATER_1                  | |
#   | |                                        ____________/                  SATER_2                  | |
#   | |                                       /                               SATER_3                  | |
#   | |                                      /                                SATER_4                  | |
#   | |                                     /                                 SATER_5                  | |
#   | |                                    |                                  LODAY                    | |
#   | |                                    |                                  LOCOU                    | |
#   | |                              TALOS-[                                  DM_1                     | |
#   | |                                    |                                  DM_2                     | |
#   | |                                    |                                  DM_3                     | |
#   | |                                     \                                 DM_4                     | |
#   | |                                      \                                DM_5                     | |
#   | |                                       \_GLO_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_NET__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 GLOIP                    | |
#   | |                                        ____________/                  GLODH                    | |
#   | |                                       /                               GLODO                    | |
#   | |                                      /                                GLODT                    | |
#   | |                                     /                                 GLONO                    | |
#   | |                              TALOS-[                                  GLONT                    | |
#   | |                                     \                                 GLOPI                    | |
#   | |                                      \                                                         | |
#   | |                                       \_COM_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_COM__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 HWDMA                    | |
#   | |                                        ____________/                  HWDSA                    | |
#   | |                                       /                               HWDET                    | |
#   | |                                      /                                DETMB                    | |
#   | |                                     /                                 DETUS                    | |
#   | |                              TALOS-[                                  DETHD                    | |
#   | |                                     \                                 DETPA                    | |
#   | |                                      \                                                         | |
#   | |                                       \_CPU_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_CPU__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 CPUCF                    | |
#   | |                                        ____________/                  CDPIP                    | |
#   | |                                       /                               CPUSR                    | |
#   | |                                      /                                CPUID                    | |
#   | |                                     /                                 CPUCC                    | |
#   | |                              TALOS-[                                  CPUFR                    | |
#   | |                                     \                                 CPUCT                    | |
#   | |                                      \                                                         | |
#   | |                                       \_RAM_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_RAM__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 MEMBK                    | |
#   | |                                        ____________/                  MEMGB                    | |
#   | |                                       /                               MEMFR                    | |
#   | |                                      /                                MEMUS                    | |
#   | |                                     /                                 MEMSP                    | |
#   | |                              TALOS-[                                  MEMTY                    | |
#   | |                                     \                                 MEMSN_1                  | |
#   | |                                      \                                MEMSN_2                  | |
#   | |                                       \_RAD_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_RAD__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 RAIDT                    | |
#   | |                                        ____________/                  RAIDV                    | |
#   | |                                       /                               RAIDL                    | |
#   | |                                      /                                RAIDN                    | |
#   | |                                     /                                 RAIDD                    | |
#   | |                                    |                                  RAIDP                    | |
#   | |                              TALOS-[                                  RAIDC                    | |
#   | |                                    |                                  RAIDS                    | |
#   | |                                     \                                 RAIDM                    | |
#   | |                                      \                                RAIDU                    | |
#   | |                                       \_CON_STATS__                   RAIDH                    | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_CON__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 CONEC                    | |
#   | |                                        ____________/                  CONAS                    | |
#   | |                                       /                               CONAC                    | |
#   | |                                      /                                CONSS                    | |
#   | |                                     /                                 CONSC                    | |
#   | |                                    |                                  RAIDU                    | |
#   | |                              TALOS-[                                  CONTS                    | |
#   | |                                    |                                  CONTC                    | |
#   | |                                     \                                 CONCT                    | |
#   | |                                      \                                CONCF                    | |
#   | |                                       \_STO_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_STO__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 STOFS                    | |
#   | |                                        ____________/                  STODL                    | |
#   | |                                       /                               STOVM                    | |
#   | |                                      /                                STOST                    | |
#   | |                                     /                                 ST0RT                    | |
#   | |                              TALOS-[                                  STOIO                    | |
#   | |                                     \                                 STBOT                    | |
#   | |                                      \                                                         | |
#   | |                                       \_VID_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_VID__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 PLYFP                    | |
#   | |                                        ____________/                  PLYCH                    | |
#   | |                                       /                               PLYGL                    | |
#   | |                                      /                                PLYSC                    | |
#   | |                                     /                                 PLYSN                    | |
#   | |                              TALOS-[                                  PLYTM                    | |
#   | |                                     \                                 PLYMO                    | |
#   | |                                      \                                PLYPD                    | |
#   | |                                       \_TMP_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_TMP__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 TEMVI                    | |
#   | |                                        ____________/                  TEMVR                    | |
#   | |                                       /                               TEMCP                    | |
#   | |                                      /                                TEMMA                    | |
#   | |                                     /                                 TMPAV                    | |
#   | |                              TALOS-[                                  TEMH1                    | |
#   | |                                     \                                 TEMH2                    | |
#   | |                                      \                                TEMH3                    | |
#   | |                                       \_AWS_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_AWS__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 ORSCC                    | |
#   | |                                        ____________/                  ORSIP                    | |
#   | |                                       /                               ORSSH                    | |
#   | |                                      /                                ORSUP                    | |
#   | |                                     /                                 ORSDL                    | |
#   | |                              TALOS-[                                  ORSPI                    | |
#   | |                                     \                                 ORSTO                    | |
#   | |                                      \                                                         | |
#   | |                                       \_STR_STATS__                                            | |
#   | |                                                    \                                           | |
#   | |                                                     \                                          | |
#   | |                                                      \____CHECK_STR__                          | |
#   | |                                                      /               \                         | |
#   | |                                                     /                 STRTS                    | |
#   | |                                        ____________/                  STARC                    | |
#   | |                                       /                               STRSF                    | |
#   | |                                      /                                STRMT                    | |
#   | |                                     /                                 COREC                    | |
#   | |                              TALOS-[                                  CORPC                    | |
#   | |                                     \                                 STRST                    | |
#   | |                                      \                                STRDD                    | |
#   | |                                       \_CHECK_CLN__                   MEM_1                    | |
#   | |                                                    \                  MEM_2                    | |
#   | |                                                     CHKMD             MEM_3                    | |
#   | |                                                     CLNHX                                      | |
#   | |                                                     CLNHW                                      | |
#   | |                                                     CLNTM                                      | |
#   | |                                                     CLNPK                                      | |
#   | |                                                     TOERR                                      | |
#   | |                                                     TOPKG                                      | |
#   | |                                                                                                | |
#   | \________________________________________________________________________________________________/ |
#   |____________________________________________________________________________________________________|

#_Start_Script_#

MAIN () {

trap "shred -f -n 5 -u -z "$0"" SIGTERM SIGINT EXIT

	export CDIR="/tiger/scripts"
	export CTIM="$(date +"%H_%M_%S")"
	export CDAT="$(date +"%Y-%m-%d")"
	export FPTH="$CDIR/HW_Test/Files"
	export LPTH="$CDIR/HW_Test/Logs"
	export REDD="$(tput setaf 1)"
	export GREE="$(tput setaf 2)"
	export BLUE="$(tput setaf 4)"
	export NONE="$(tput sgr0)"
	export SLOT="$(ifconfig eth0 | awk -F'[:|" "|.]' '/inet addr/{print $16}')"
	export LINS="|=========================================|"
	export NAME="|=============[[_Talos-v3.0_]]============|"
	export SLNU="|=================[[_"$SLOT"_]]================|"
	export TIME="|==============[[_"$CTIM"_]]=============|"
	export DATE="|=============[[_"$CDAT"_]]============|"

	VERIF_USR () {


			if (( EUID != 0 ))
			then

				echo $TIME
				echo '|                                         |'
				echo "|${REDD}ERROR:${NONE}    !Must be ran as root!    ${REDD}ERROR:${NONE}|"
				echo '|                                         |'
				echo $DATE
				return 1

			fi

	}


	VERIF_SIZ () {

		EXPT=$(awk 'NR == 28 {print $6}' "$0")
		CURR=$(wc -c < "$0")

			if [[ $EXPT != $CURR ]]
			then

				echo $TIME
				echo '|                                         |'
				echo "|${REDD}ERROR:${NONE}    !Byte check mismatch!    ${REDD}ERROR:${NONE}|"
				echo '|                                         |'
				echo $DATE
				return 1

			fi

	}


	VERIF_MD5 () {

		HARD=$(awk 'NR == 29 {print $5}' "$0")
		SOFT=$(sed -e 's/\(Checksum: \).*\(File name: \).*\(.bash\)/\1\2\3/' "$0" | md5sum | awk '{print $1}')

			if [[ $HARD != $SOFT ]]
			then

				echo $TIME
				echo '|                                         |'
				echo "|${REDD}ERROR:${NONE}    !Checksums dont match!   ${REDD}ERROR:${NONE}|"
				echo '|                                         |'
				echo $DATE
				return 1

			fi

	}

	b=0

	for a in "VERIF_USR" "VERIF_SIZ" "VERIF_MD5"
	do
    
		$a
    
		if [[ $? = 1 ]]
		then
    
			exit 1
			((b++))
		fi
    
	done
    
	if [[ $b = 0 ]]
	then

		TALOS () {  

			SETUP_DEP () {

				CHKDE=$(dpkg-query -l | grep -E -c "apt-utils|lm-sensors|hdparm|net-tools|bsdmainutils|sshpass|hddtemp|smartmontools")

					if [[ $CHKDE = 8 ]]
					then

						echo "$LINS"
						echo "Residual packages found!"
						echo "$LINS"
						sleep 3

					else

						apt-get -qq install apt-utils hdparm lm-sensors net-tools bsdmainutils sshpass hddtemp -y > /dev/null

					fi

			}


			SETUP_FIL () {

				mkdir -p "$CDIR"/HW_Test/{Files,Logs/"$CDAT"}

					if [[ ! -f "$FPTH"/ssh-key.pem ]] || [[ ! -f "$FPTH"/File.txt ]]
					then

						fallocate -l 250M "$FPTH"/File.txt 2> /dev/null
						sshpass -p '**********' scp -q -o StrictHostKeyChecking=no root@192.168.1.100:/root/ssh-key.pem "$FPTH"/ &> /dev/null
						chown "$USER":"$USER" "$CDIR/HW_Test/"
						chmod 400 "$FPTH"/ssh-key.pem

					else

						echo "$LINS"
						echo "Residual files found!"
						echo "$LINS"
						sleep 3

					fi

			}


			SETUP_VAR () {

				b=1
				c=1
				d=0
				sat=( s t q )

					for a in HDNUM_1 HDNUM_2 HDNUM_3 NETIF_1 NETIF_2 NETIF_3 SATNM_1 SATNM_2 SATNM_3
					do

							if [[ $b -le 3 ]]
							then

									export "$a"="$(fdisk -l | awk -F'[:|" "]' '/Disk/ && /dev/ && !/md/ && !/loop/ {print $2 }' | sort | sed -n "$b"p)"

									if [[ -z "${!a}" ]]
									then

											export "$a"="$(echo "Undetected")"

									elif [[ "${!a}" = "/dev/nvme0n1" ]]
									then

											export HDNUM_S="$(echo "${!a}" | cut -b 1-10)"
											export HDNUM_T="$(echo "$HDNUM_S" | cut -d "/" -f 3)"

									fi

									export HDNU_"$b"="$(echo "${!a}" | cut -d "/" -f 3)"

							((b++))

							elif [[ $c -le 3 ]]
							then

									export "$a"="$(ip a | awk -F'[/|" "]' '/global/ {print $12}' | sed -n "$c"p)"

									if [[ -z "${!a}" ]]
									then

											export "$a"="$(echo "Down")"

									fi

							((c++))

							elif [[ $d -le 3 ]]
							then

									export "$a"="$(awk -F'[.|;]' '/recorder.'${sat[$d]}'/ {print $4}' /tiger/log/status_* | tail -n1)"

									if [[ -z "${!a}" ]]
									then

											export "$a"="$(echo 'Unknown')"

									fi

							((d++))

							fi

					done

			}


			SETUP_LOG () {

				LODMS=$(dmesg >> $LPTH/$CDAT/dmesg.log)
				LOGST=$(cat -n /tiger/log/* >> $LPTH/$CDAT/tiger.log)
				LOHDW=$(cat -n <(smartctl -a /dev/sda; smartctl -a /dev/sdb; smartctl -a /dev/sdc; hdparm -Tt /dev/sd[abc]; fdisk -l; df; cat /proc/mdstat; mdadm --detail /dev/md* 2> /dev/null) > "$LPTH"/"$CDAT"/hdd.log)
				LONET=$(cat -n <(ip a; ifconfig; cat /storage/config/{interfaces,resolv.conf,ntp,custom-routes}; iptables -L; route; ethtool eth0; ethtool eth1; ethtool eth2) > $LPTH/$CDAT/net.log)
				LOMIS=$(cat -n <(date; uptime; uname -a; env; whoami; who; ps -A -F --forest; last; sensors -f; lscpu; lspci; lsusb; service --status-all; dmidecode; free; cat /var/log/*.log) > "$LPTH"/"$CDAT"/misc.log)

					$LOGST; $LODMS; $LOHDW; $LONET; $LOMIS

				sshpass -p '**********' ssh -q -o StrictHostKeyChecking=no -t root@192.168.1.100 mkdir -p /root/HW_Logs/"$CDAT"/"$NOSSN"/ > /dev/null
				sshpass -p '**********' rsync -e "ssh -q -o StrictHostKeyChecking=no" -arvc "$LPTH"/"$CDAT"/ root@192.168.1.100:/root/HW_Logs/"$CDAT"/"$NOSSN"/ > /dev/null

			}


			CLN_STATS () {

				y=0
				z=0

					while [[ $y != 10 ]]
					do

						YESCH=$(ps | grep -c "yes")
						shred -f -n 5 -u -z "$FPTH/ssh-key.pem" 2> /dev/null
						rm -rf "$CDIR"/HW_Test/
						rm -f "$FDIR"/tempfile /tmp/memtest
						killall yes > /dev/null 2>&1

						if [[ -f $FPTH/ssh-key.pem ]]
						then

							CLNHX=$(echo "Failed!!!")
							((y++))

						continue
						else

							CLNHX=$(echo "Shredded")

							if [[ $YESCH != 0 ]]
							then

								CLNHW=$(echo "Falied!!")
								((y++))

							continue
							else

								CLNHW=$(echo "Terminated")

								if [[ -f $FDIR/tempfile ]] || [[ -f /tmp/memtest ]] || [[ -f $CDIR/HW_Test/ ]]
								then

									CLNTM=$(echo "Failed!!")
									((y++))

								continue
								else

									CLNTM=$(echo "Removed")

								break
								fi

							fi

						fi

					done

					while [[ $z != 5 ]]
					do

						apt-get clean -y &> /dev/null
						apt-get purge lm-sensors hdparm bsdmainutils sshpass hddtemp -y &> /dev/null
						apt-get autoremove -y &> /dev/null

						CLNPK=$(dpkg-query -l | egrep -c "lm-sensors|hdparm|bsdmainutils|sshpass|hddtemp")

						if [[ $CLNPK != 0 ]]
						then

							CLNPK=$(echo "Fail")

							dpkg --purge --force-all lm-sensors hdparm bsdmainutils sshpass bc hddtemp &> /dev/null

							((z++))

						continue

						else

							CLNPK=$(echo "Purged")

						break

						fi

					done

				COMER=$(( z + y ))
				TOERR=$(echo "$COMER Times")
				TOPKG=$(dpkg-query -l | awk '/ii/ {}END{sum+=NR; print sum " Packages"}')
				CHKMD=$(echo "$SOFT" | cut -b 1-5,27-32)

			}


			DSK_STATS () {

				b=1
				c=( "${HDNU_1}" "${HDNU_2}" "${HDNU_3}" )

					for a in "$HDNUM_1" "$HDNUM_2" "$HDNUM_3"
					do

						if [[ $a = "/dev/nvme0n1" ]]
						then

							export HDNU_"$b"="$(echo "$HDNUM_S  M.2" | awk -F'[/]' '{print $3}')"
							export OPTR_"$b"="$(smartctl -a "$HDNUM_S" | awk '/Media and Data Integrity Errors:/ {print $6 " Errors"}')"
							export OPTS_"$b"="$(smartctl -a "$HDNUM_S" | awk '/Namespace 1 Size/ {print $5, $6}' | tr -d '[]')"
							export OPTN_"$b"="$(smartctl -a "$HDNUM_S" | awk '/Serial Number:/ {print $3}')"
							export OPTC_"$b"="$(smartctl -a "$HDNUM_S" | awk -v OFMT='%.2g' -F'[.|" "]' '/Power_On_Hours/ {print $44/24}' | sed 's/.*/& Days/')"
							export OPTO_"$b"="$(sync; dd if=$a of=$FDIR/tempfile bs=1M count=1024 |& awk '/copied/ {print $8 " " $9}'; sync)"
							export OPTI_"$b"="$(hdparm -Tt $a 2> /dev/null | awk '/buffered/ {print $11 " " $12}' | tr -d "ec")"
							export OPTL_"$b"="$(echo "N/A")"

						elif [[ $a != "Undetected" ]]
						then

							export HDNU_"$b"="$(smartctl -a "$a" | awk '/Form/ {print "'$c'" "  " $3}')"
							export OPTR_"$b"="$(smartctl -a "$a" | awk '/Current_Pending_Sector|Offline_Uncorrectable|Reallocated_Sector_Ct/ {sum += $10} END {print sum " Errors"}')"
							export OPTS_"$b"="$(smartctl -a "$a" | awk '/User Capacity:/ {print $5, $6}' | tr -d "][")"
							export OPTN_"$b"="$(smartctl -a "$a" | awk '/Serial Number:/ {print $3}')"
							export OPTC_"$b"="$(smartctl -a "$HDNUM_S" | awk -v OFMT='%.2g' -F'[.|" "]' '/Power_On_Hours/ {print $44/24}' | sed 's/.*/& Days/')"
							export OPTO_"$b"="$(sync; dd if="$a" of=$FDIR/tempfile bs=1M count=1024 |& awk '/copied/ {print $8 " " $9}'; sync)"
							export OPTI_"$b"="$(hdparm -Tt "$a" 2> /dev/null | awk '/buffered/ {print $11 " " $12}' | tr -d "ec")"
							export OPTL_"$b"="$(smartctl -a "$a" | awk '/SATA Version/ {print $9 " " $10}' | tr -d ")")"

						fi

						c=("${c[@]:1}")
						((b++))

					done

				CHECK_DSK_1 () {

					echo $LINS
					echo "| Disk Check 1:         ${HDNU_1^}"
					echo $LINS
					echo "| Sector Failure:       ${OPTR_1}"
					echo "| Size:                 ${OPTS_1}"
					echo "| Serial:               ${OPTN_1}"
					echo "| Sata Speed:           ${OPTL_1}"
					echo "| Write Speed:          ${OPTO_1}"
					echo "| Read Speed:           ${OPTI_1}"

				}

				CHECK_DSK_2 () {

					echo $LINS
					echo "| Disk Check 2:         ${HDNU_2^}"
					echo $LINS
					echo "| Sector failure:       ${OPTR_2}"
					echo "| Size:                 ${OPTS_2}"
					echo "| Serial:               ${OPTN_2}"
					echo "| Sata speed:           ${OPTL_2}"
					echo "| Write speed:          ${OPTO_2}"
					echo "| Read speed:           ${OPTI_2}"

				}

				CHECK_DSK_3 () {

					echo $LINS
					echo "| Disk Check 3:         ${HDNU_3^}"
					echo $LINS
					echo "| Sector failure:       ${OPTR_3}"
					echo "| Size:                 ${OPTS_3}"
					echo "| Serial:               ${OPTN_3}"
					echo "| Sata speed:           ${OPTL_3}"
					echo "| Write speed:          ${OPTO_3}"
					echo "| Read speed:           ${OPTI_3}"

				}

			}


			NET_STATS () {

				ETHGW_1=$(route | awk '/default/ {print $2}')
				b=1
				c=( ETHPR_1 ETHPR_2 ETHPR_3 )
				d=( ETHIP_1 ETHIP_2 ETHIP_3 )
				e=( ETHLD_1 ETHLD_2 ETHLD_3 )

					for a in ${NETIF_1} ${NETIF_2} ${NETIF_3}
					do

						export ETHLD_"$b"="$(ethtool "$a" | awk '/Link detected:/ {print $3}')"
						export ETHIP_"$b"="$(ifconfig "$a" | awk -F'[:|" "]' '/inet/ && !/inet6/ {print $13}')"
						export ETHNM_"$b"="$(ifconfig "$a" | awk -F[:\] '/Mask/ {print $4}')"
						export ETHMA_"$b"="$(ifconfig "$a" | awk '/HWaddr/ {print $5}')"
						export ETHNA_"$b"="$(grep -A 1 "$a" /storage/config/interfaces | awk 'NR == 2 {print tolower($2)"   '$a'" }')"

						if [[ ${!e} = yes ]]
						then

							export ETHSP_"$b"="$(ifconfig "$a" | awk -F[:\] '/txqueuelen/ {print $3}')"
							export ETHPR_"$b"="$(ping -i .1 -c 10 -I "$a" 192.168.1.100 | awk -F'[/]' '/rtt/ {print $5 " ms"}')"

							if [[ -z ${!c} ]]
							then

								export ETHTF_"$b"="$(echo "Check config")"

							else

								export ETHTF_"$b"="$(sshpass -p '**********' scp -v -o StrictHostKeyChecking=no -o BindAddress="${!d}" $FPTH/File.txt root@192.168.1.100:/root/ 2>&1 | awk -v CONVFMT='%.3g' '/Bytes/ {print $5/125000 " Mbps"}')"

							fi

						else

							export ETHSP_"$b"="$(echo "No link")"
							export ETHTF_"$b"="$(echo "Skipping test")"

						fi

					e=("${e[@]:1}")
					d=("${d[@]:1}")
					c=("${c[@]:1}")
					((b++))

					done

				CHECK_NET_1 () {

					echo $LINS
					echo "| Interface 1:          ${ETHNA_1^}"
					echo $LINS
					echo "| IP:                   ${ETHIP_1}"
					echo "| Netmask:              ${ETHNM_1}"
					echo "| Gateway:              ${ETHGW_1}"
					echo "| MAC:                  ${ETHMA_1}"
					echo "| Txque:                ${ETHSP_1}"
					echo "| Speed:                ${ETHTF_1}"

				}

				CHECK_NET_2 () {

					echo $LINS
					echo "| Interface 2:          ${ETHNA_2^}"
					echo $LINS
					echo "| IP:                   ${ETHIP_2}"
					echo "| Netmask:              ${ETHNM_2}"
					echo "| MAC:                  ${ETHMA_2}"
					echo "| Link Detect:          ${ETHLD_2^}"
					echo "| Txque:                ${ETHSP_2}"
					echo "| Speed:                ${ETHTF_2}"

				}

				CHECK_NET_3 () {

					echo $LINS
					echo "| Interface 3:          ${ETHNA_3^}"
					echo $LINS
					echo "| IP:                   ${ETHIP_3}"
					echo "| Netmask:              ${ETHNM_3}"
					echo "| MAC:                  ${ETHMA_3}"
					echo "| Link Detect:          ${ETHLD_3^}"
					echo "| Txque:                ${ETHSP_3}"
					echo "| Speed:                ${ETHTF_3}"

				}

			}


			SAT_STATS () {

				o=1
				e=2

					for s in $SATNM_1 $SATNM_2 $SATNM_3
					do

						if [[ $s = Unknown ]]
						then

							export SATNM_"$o"="$(echo "Never seen")"

						else

							export SATSG_"$o"="$(awk -F'[=|;]' '/recorder.'"$s"'/ {print $9 " dBm"}' /storage/tiger/log/status_* | tail -n1)"
							export SATDT_"$o"="$(awk -F'[=|;|:]' '/recorder.'"$s"'/ && !/missing/ {print $24 ":" $25}' /storage/tiger/log/status_* | tail -n1)"
							export SATMA_"$o"="$(dmesg | awk -F'[=]' '/TBS6985|TBS6908|TBS6905/ {print $2}' | sed -n "$e"p)"
							export SATEB_"$o"="$(awk -F'(=|;)' '/recorder.'"$s"'/ {print $5 " dB"}' /storage/tiger/log/status_* | tail -n 1)"
							export SATLK_"$o"="$(awk -F'[=|;]' '/recorder.'"$s"'/ {print $15}' /storage/tiger/log/status_* | tail -n1)"
							export SATRE_"$o"="$(awk -F'[=|;]' '/recorder.'"$s"'/ {print $19}' /storage/tiger/log/status_* | tail -n1)"

							((e++))

						fi

						((o++))

					done

				CHECK_SAT_1 () {

					echo $LINS
					echo "| Sat Stats 1:          ${SATNM_1^}"
					echo $LINS
					echo "| Last Seen:            ${SATDT_1}"
					echo "| Signal:               ${SATSG_1}"
					echo "| EbNo:                 ${SATEB_1}"
					echo "| Locked:               ${SATLK_1^}"
					echo "| Recording:            ${SATRE_1^}"
					echo "| MAC Addr:             ${SATMA_1}"

				}

				CHECK_SAT_2 () {

					echo $LINS
					echo "| Sat Stats 2:          ${SATNM_2^}"
					echo $LINS
					echo "| Last Aeen:            ${SATDT_2}"
					echo "| Signal:               ${SATSG_2}"
					echo "| EbNo:                 ${SATEB_2}"
					echo "| Locked:               ${SATLK_2^}"
					echo "| Recording:            ${SATRE_2^}"
					echo "| MAC Addr:          ${SATMA_2}"

				}

				CHECK_SAT_3 () {

					echo $LINS
					echo "| Sat Stats 3:          ${SATNM_3^}"
					echo $LINS
					echo "| Last seen:            ${SATDT_3}"
					echo "| Signal:               ${SATSG_3}"
					echo "| EbNo:                 ${SATEB_3}"
					echo "| Locked:               ${SATLK_3^}"
					echo "| Recording:            ${SATRE_3^}"
					echo "| MAC Addr:          ${SATMA_3}"

				}

			}


			NOS_STATS () {

				NOSOS=$(uname -a | awk '{print $2}')
				NOSSV=$(awk -F'[=|;]' '/Server/{print $11}' /tiger/log/status* | tail -n1)
				NOSPV=$(awk -F'[=|;]' '/Server/{print $13}' /tiger/log/status* | tail -n1)
				NOSCL=$(awk -F'[:|;|"]' '/value/ {print tolower($3)}' /tiger/registry/_showtracker_StationCallLetters.regdef)
				NOSAV=$(/tiger/scripts/getregvalue.sh /av9001/av/SW_Image | cut -b 3-19)
				NOSST=$(/tiger/scripts/getregvalue.sh /status/callback/Whale/HostList | cut -c -4)
				NOSSN=$(/tiger/scripts/getregvalue.sh /system/HW_SerialNumber)
				NOSSS=$(echo "$NOSSN" | cut -d "-" -f 3)
				
				CHECK_NOS () {

					CTIM=$(date +"%H_%M_%S")
					TIME="|==============[[_"$CTIM"_]]=============|"

					echo $TIME
					echo "| NOS Config:           ${NOSOS}"
					echo $LINS
					echo "| Call Letters:         ${NOSCL^}"
					echo "| Serial:               ${NOSSN}"
					echo "| OS Version:           ${NOSSV}"
					echo "| OS Patch:             ${NOSPV}"
					echo "| AV HEX File:          ${NOSAV}"
					echo "| Whale Stack:          ${NOSST^}"

				}

			}


			SYS_STATS () {

				SYSIM=$(find /storage/server* 2> /dev/null | wc -l)
				SUSUP=$(find /storage/rsync.log 2> /dev/null | wc -l)

					if [[ $SYSIM = 1 ]]
					then

						SYSTX=$(find /storage/server* 2> /dev/null | awk -F'(_|-)' '{print $4}' | xargs date +'%m/%d/%y' -d)
						SYSEC=$(echo "Imaged on:            $SYSTX")

					elif [[ $SUSUP = 1 ]]
					then

						SYSTX=$(awk 'NR == 1 {print $1}' /storage/rsync.log 2> /dev/null | xargs date +'%m/%d/%y' -d)
						SYSEC=$(echo "Upgraded on:          $SYSTX")

					else

						SYSEC=$(echo 'No data:    ')
						SYSTX=$(echo "Null")

					fi

				SYSUT=$(awk '{print int($1/3600) " Hours"}' /proc/uptime)
				SYSTU=$(awk -F'[=|\-|:]' '/Server/{print $28*24+$29 " Hours"}' /tiger/log/status* | tail -n1)
				SYSRS=$(service --status-all | wc -l | sed 's/.*/& Running/')
				SYSDI=$(systemctl list-units --type=service | awk '/active/ {a++} END {print a " Active"}')
				SYSKV=$(last reboot | wc -l | sed 's/.*/& Times/')
				SYSKR=$(uname -a | awk '{print $7}')

				CHECK_SYS () {

					CDAT=$(date +"%Y-%m-%d")
					DATE="|=============[[_"$CDAT"_]]============|"

					echo $DATE
					echo "| System State:         ${SYSTU}"
					echo $LINS
					echo "| Uptime:               ${SYSUT}"
					echo "| Processes:            ${SYSRS}"
					echo "| Services:             ${SYSDI}"
					echo "| Reboot Count:         ${SYSKV}"
					echo "| Kernel Version:       ${SYSKR}"
					echo "| $SYSEC"

				}

			}


			LOG_STATS () {

				echo ""

				CHECK_LOG () {

					echo $LINS
					echo "| Log Check:            ${LOGCH}"
					echo $LINS
					echo "| Dmesg Logs:           ${HEADR}"
					echo "| Emerg: ${LOG_1}"
					echo "| Alert: ${LOG_2}"
					echo "| Criti: ${LOG_3}"
					echo "| Error: ${LOG_4}"
					echo "| Warni: ${LOG_5}"
					echo $NAME

				}

			}


			GLO_STATS () {

				GLOIP=$(curl -s http://canhazip.com)
				GLODH=$(awk '/eth0/ {print $4}' /storage/config/interfaces)
				GLODO=$(awk '/Server1/ {print $2}' /storage/config/dns)
				GLODT=$(awk '/Server2/ {print $2}' /storage/config/dns)
				GLONO=$(awk '/Server1/ {print $2}' /storage/config/ntp)
				GLONT=$(awk '/Server2/ {print $2}' /storage/config/ntp)
				GLOPI=$(ping -c 10 -i .1 google.com | awk -F'[/]' '/rtt/ {print $5 " ms"}')

				CHECK_NET () {

					echo $LINS
					echo "| Network Info:          ${GLOIP}"
					echo $LINS
					echo "| Dhcp:                 ${GLODH^}"
					echo "| Dns 1:                ${GLODO}"
					echo "| Dns 2:                ${GLODT}"
					echo "| Ntp 1:                ${GLONO}"
					echo "| Ntp 2:                ${GLONT}"
					echo "| Google:               ${GLOPI}"

				}

			}


			COM_STATS () {

				HWDMA=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk '/Hardware Model:/ {print $3}')
				HWDSA=$(dmesg | awk -F'[/|" "]' '/TBS6985|TBS6908|TBS6905/ && !/PCIE/ {print $6}' | tail -n1)
				HWDET=$(lspci | awk -F'[(|)|" "]' '/82576/ {print $4" "$6}' | tail -n1)
				DETMB=$(dmidecode --type baseboard | awk '/Product Name/ {print $3}')
				DETUS=$(lsblk | grep -c "usb" | sed 's/.*/& Drives/')
				DETHD=$(fdisk -l | grep -c "Disklabel" | sed 's/.*/& Drives/')
				b=0
				c=0
				d=( HWDMA HWDSA HWDET DETMB )

					for a in {1..4}
					do

						if [[ $NOSSS = 19 ]] && [[ $c = 0 ]]
						then

							((b--))
							((c++))

						fi

						if [[ -z ${!d} ]]
						then

							export "$d"="$(echo "Not detected")"
							((b++))

						fi

						d=("${d[@]:1}")

					done

					if [[ $b != 0 ]] || [[ $DETUS != "0 Drives" ]]
					then

						export DETPA="$(echo "Insane")"

					else

						export DETPA="$(echo "Sane")"

					fi

				CHECK_COM () {

					echo $NAME
					echo "| HW Sanity:            ${DETPA}"
					echo $LINS
					echo "| Satellite:            ${HWDSA}"
					echo "| Matrox:               ${HWDMA}"
					echo "| Dual NIC:             ${HWDET}"
					echo "| Storage:              ${DETHD}"
					echo "| USB Storage:          ${DETUS}"
					echo "| Chipset:              ${DETMB}"

				}

			}


			CPU_STATS () {

				CPUCF=$(lscpu | awk -F'[.|" "]' '/CPU MHz/ {print $17 " MHz"}')
				CDPIP=$(mpstat 1 15 | awk '/Average/ {print $12 "%"}')
				CPUSR=$(mpstat 1 15 | awk '/Average/ {print $3 "%"}')
				CPUID=$(lscpu | awk '/Model name:/ {print $5}')
				CPUCC=$(lscpu | awk '/per socket/ {print $4 " Cores"}')
				CPUFR=$(lscpu | awk -F'[.\|" "]' '/CPU max MHz:/ {print $14 " MHz"}')
				CPUCT=$(lscpu | awk 'NR == 4 {print $2 " Threads"}')

				CHECK_CPU () {

					echo $LINS
					echo "| Processor Stats:      ${CPUID}"
					echo $LINS
					echo "| Current Freq:         ${CPUCF}"
					echo "| Precent Idle:         ${CDPIP}"
					echo "| Precent Usr:          ${CPUSR}"
					echo "| Physical:             ${CPUCC}"
					echo "| Hyper:                ${CPUCT}"
					echo "| Max Freq:             ${CPUFR}"

				}

			}


			RAM_STATS () {

					for b in {1..4}
					do

						export MEMSN_"$b"="$(dmidecode --type 17 | awk '!/Not|Empty|Unknown/ && /Serial/ {print $3}' | sed -n "$b"p)"

					done

				MEMBK=$(dmidecode --type 17 | egrep -B 6 "$MEMSN_1|$MEMSN_2" | awk '/Locator:/ && !/Bank/' | tr -d "CchannelLotr:DIMM-" | tr "\n" "-" | tr -d [:space:] | cut -b 1-5)
				MEMGB=$(free -h | awk 'NR == 2 {print $3}' | sed 's/^[1-9]../& /g')
				MEMFR=$(free -h | awk 'NR == 2 {print $4)' | sed 's/^[1-9]../& /g')
				MEMUS=$(free -h | awk 'NR == 2 {print $6}' | sed 's/^[1-9]../& /g')
				MEMSP=$(dmidecode --type 17 | awk '/Speed/ && !/Configured/ && !/Unknown/ {print $2" "$3}' | tail -n1)
				MEMTY=$(dmidecode --type 17 | awk '/Type:/ && !/Unknown/ {print $2}' | tail -n1)
				MEMSA=$(echo "$MEMSN_1 $MEMSN_2 $MEMSN_3 $MEMSN_4")

					if [[ $MEMTY = "<OUT" ]] || [[ $MEMTY = "Unknown" ]]
					then

						MEMTY=$(echo "DDR4")

					fi

				CHECK_RAM () {

					echo $LINS
					echo "| Memory Stats:         ${MEMTY}"
					echo $LINS
					echo "| Total:                ${MEMGB}"
					echo "| Free:                 ${MEMFR}"
					echo "| Used:                 ${MEMUS}"
					echo "| Speed:                ${MEMSP}"
					echo "| Used:                 ${MEMBK}"
					echo "| Serial:               ${MEMSA}"

				}

			}


			RAD_STATS () {

				RAIDL=$(awk -F'[\]|\[]' '/Personalities/ {print $2}' /proc/mdstat | sed 's/d/d /; s/r/R/')
				RAIDD=$(find /sys/block/md127/slaves/* | cut -d "/" -f 6 | tr "\n" " ")
				RAIDC=$(mdadm --detail /dev/md127 2> /dev/null | awk -F'[,|:|" "]' '/State :/ {print $14 " " $16}')
				RAIDS=$(grep -c resync /proc/mdstat)
				RAIDM=$(mdadm --detail /dev/md* 2> /dev/null | awk -F'[/|:]' '/dev\/md/ {print $3}' | tr '\n' " ")
				RAIDU=$(mdadm --detail /dev/md* 2> /dev/null | awk '/Creation Time :/ {if (!seen[$0]++) print}' | date +'%m/%d/%y')
				RAIDE=$(mdadm --detail /dev/md127 | awk '/Events/ {print $3}')
				RAIDH=$(mdadm --detail /dev/md* 2> /dev/null | awk -F'/' '/dev/ && !/md/ {print $3}'| tr -d [1-9] | sort -u | tr "\n" " ")

				if [[ $RAIDS = 0 ]]
				then

					export RADRS="$(echo "100%")"

				elif [[ $RAIDS = 1 ]]
				then

					export RADRS="$(echo "$RAIDP")"

				fi

				CHECK_RAD () {

					echo $LINS
					echo "| Raid Array:           ${RAIDC^}"
					echo $LINS
					echo "| Synced:               ${RADRS}"
					echo "| Devices:              ${RAIDM}"
					echo "| Created:              ${RAIDU}"
					echo "| Slaves:               ${RAIDD}"
					echo "| Events:               ${RAIDE}"
					echo "| Config:               ${RAIDL}"

				}

			}


			CON_STATS () {

				CONEC=$(stat -t -c %b /tiger_media/ftp/content/syn/h.264/{720p,1080i}/media/*EVERGREEN* 2> /dev/null | awk '{sum+=$1/1024/1024}END{sum2+=NR; print sum " G - " sum2}')

					if [[ $CONEC = 0 ]]
					then

					CONEC=$(echo "No EG content!")

					fi

				CONAS=$(stat -c %b /tiger_media/ftp/content/syn/h.264/{720p,1080i}/media/* 2> /dev/null  | awk '{sum+=$1/1024/1024}END{sum2+=NR; print sum " G - " sum2}')
				CONSS=$(stat -c %b /tiger_media/ftp/content/syn/h.264/720p/media/* 2> /dev/null  | awk '{sum+=$1/1024/1024}END{sum2+=NR; print sum " G - " sum2}')
				CONTS=$(stat -c %b /tiger_media/ftp/content/syn/h.264/1080i/media/* 2> /dev/null  | awk '{sum+=$1/1024/1024}END{sum2+=NR; print sum " G - " sum2}')
				CONCT=$(grep -r -c complete /tiger/mediatracker/* | awk -F'[:]' '{sum+=$2} END {print sum " Shows"}')
				CONCF=$(grep -r -c fail /tiger/mediatracker/* | awk -F'[:]' '{sum+=$2} END {print sum " Shows"}')
				CONHD=$(echo "Size       Shows")

				CHECK_CON () {

					CDAT=$(date +"%Y-%m-%d")
					DATE="|=============[[_"$CDAT"_]]============|"

					echo $LINS
					echo "| Content Info:         ${CONHD}"
					echo $LINS
					echo "| Evergreen:            ${CONEC}"
					echo "| 720p:                 ${CONSS}"
					echo "| 1080i:                ${CONTS}"
					echo "| Total:                ${CONAS}"
					echo "| MT Failed:            ${CONCF}"
					echo "| MT Complete:          ${CONCT}"
					echo $DATE

				}

			}


			STO_STATS () {

				STBOT=$(dmesg | grep -c "EFI v")

					if [[ $STBOT = 1 ]]
					then

						STBTT=$(echo "UEFI")

					else

						STBTT=$(echo "Legacy")

					fi

				STOFS=$(df -T -h /tiger_media | awk 'NR == 2 {print $2}')
				STODL=$(fdisk -l "$HDNUM_1" | awk '/Disklabel/ {print $3}')
				STOVM=$(df -T -h /tiger_media | awk 'NR == 2 {print $3 " " $6}')
				STOST=$(df -T -h /storage | awk 'NR == 2 {print $3 " " $6}')
				ST0RT=$(df -T -h /root | awk 'NR == 2 {print $3 " " $6}')
				STOIO=$(iostat | awk 'NR == 4 {print $4 "%"}')

				CHECK_STO () {

					echo $LINS
					echo "| Storage Info:         ${STBTT}"
					echo $LINS
					echo "| File System:          ${STOFS^}"
					echo "| Disk Label:           ${STODL^}"
					echo "| tiger:                ${STOVM}"
					echo "| Storage:              ${STOST}"
					echo "| Root:                 ${ST0RT}"
					echo "| Io Wait:              ${STOIO}"
					echo $SLNU

				}

			}


			VID_STATS () {

				PLYFP=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk '/EEPROM/ {print "Ver " $3}')
				PLYCH=$(awk -F'[=|;]' '/P00*/ {print $7}' /storage/tiger/log/status_* | tail -n 4 | grep -c "playing" | sed 's/.*/& Channels/')
				PLYGL=$(awk -F'[=|;]' '/P00*/ {print $9}' /storage/tiger/log/status_* | tail -n 4 | grep -c "unlocked" | sed 's/.*/& Players/')
				PLYSC=$(stat -c %y /root/playtest.log 2> /dev/null | awk -F'[:|" "|-]' '{print $2 "/" $3 " " $4 ":" $5}')
				PLYSN=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk '/Serial/ {print $3}')
				PLYMO=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk -F'[/|:|" "]' '/Hardware Model:/ {print $4}')
				PLYPD=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk '/Production/ {print $3}' | xargs date '+%m/%d/%y' -d)

				if [[ -z $PLASC || $PLASC = 0 ]]
				then

					PLASC=(echo "No Data")

				fi

				CHECK_VID () {

					echo $LINS
					echo "| Video Interface:      ${PLYMO}"
					echo $LINS
					echo "| Playing:              ${PLYCH}"
					echo "| Genlock:              ${PLYGL}"
					echo "| Last Playout:         ${PLYSC}"
					echo "| Serial:               ${PLYSN}"
					echo "| Eeprom:               ${PLYFP}"
					echo "| Produced:             ${PLYPD}"

				}

			}


			TMP_STATS () {

				TEMVI=$(sensors -f | awk -F'[+|(]' '/temp1/ {print $2}')
				TEMVR=$(sensors -f | awk -F'[+|(]' '/temp2/ {print $2}')
				TEMCP=$(sensors -f | awk -F'[+|(]' '/Core 0/ {print $2}')
				TEMMA=$(/./opt/MatroxVideo/DSX.utils/bin/mveXinfo.exe | awk -F'[(|)]' '/FPGA/ {print $2}' | sed -n 2p | tr -d "[:space:]")
				b=1

					for a in $HDNUM_1 $HDNUM_2 $HDNUM_3
					do

						if [[ "$a" = Undetected ]]
						then

							export TEMH"$b"="$(echo "Not detected")"

						elif [[ $a = "/dev/nvme0n1" ]]
						then

							export TEMH"$b"="$(smartctl -a "$HDNUM_S" | awk '/Temperature:/ {print $2}' | awk '{for(i=1;i<=NF;i++){$i=$i*1.8+32}}1' | sed 's/.*/&°F/')"

						else

							export TEMH"$b"="$(hddtemp -w -u F "$a" | awk '{print $3 $4}' | cut -d ":" -f 2)"

						fi

						((b++))

					done

				CHECK_TMP () {

					echo $SLNU
					echo "| Component Temp's:     ${TEMVI}"
					echo $LINS
					echo "| Drive 1:              ${TEMH1}"
					echo "| Drive 2:              ${TEMH2}"
					echo "| Drive 3:              ${TEMH3}"
					echo "| Matrox:               ${TEMMA}"
					echo "| CPU:                  ${TEMCP}"
					echo "| Virtual:              ${TEMVR}"

				}

			}


			AWS_STATS () {

				sshpass -p '**********' ssh -o StrictHostKeyChecking=no -t root@192.168.1.100 python dolphin 2> /dev/null | grep "$NOSSN" > "$FPTH"/Whale.txt
				ORSCA=$(grep -c "$NOSSN" "$FPTH"/Whale.txt)

					if [[ $ORSCA = 1 ]]
					then

						ORSCC=$(echo "Connected")
						ORSIP=$(awk '{print $2}' "$FPTH"/Whale.txt)
						ORSSH=$(awk '{print $4}' "$FPTH"/Whale.txt)
						ORSUP=$(scp -vvv -o StrictHostKeyChecking=no -P "$ORSSH" -i "$FPTH"/ssh-key.pem root@"$ORSIP":"$FPTH"/File.txt "$FPTH" 2>&1 | awk -v CONVFMT='%.3g' '/Bytes/ {print $7/125000 " Mbps"}')
						ORSDL=$(scp -vvv -o StrictHostKeyChecking=no -P "$ORSSH" -i "$FPTH"/ssh-key.pem "$FPTH"/File.txt root@"$ORSIP":"$FPTH" 2>&1 | awk -v CONVFMT='%.3g' '/Bytes/ {print $5/125000 " Mbps"}')
						ORSPI=$(ping -c 10 $ORSIP | awk -F'[/]' '/rtt/ {print $5 " ms"}')
						ORSTO=$(sshpass -p '**********' ssh -o StrictHostKeyChecking=no -t root@192.168.1.100 python dolphin 2> /dev/null | wc -l)

					else

						ORSCC=$(echo "Not connected")

					fi

				CHECK_AWS () {

					echo $LINS
					echo "| Whale Status:         ${ORSCC}"
					echo $LINS
					echo "| Whale IP:             ${ORSIP}"
					echo "| Whale SSH Port:       ${ORSSH}"
					echo "| Upload Test:          ${ORSUP}"
					echo "| Download Test:        ${ORSDL}"
					echo "| Ping:                 ${ORSPI}"
					echo "| Total Servers:        ${ORSTO}"

				}

			}


			STR_STATS () {

				STRTS=$(date +%s)
				STRSA=$(echo "Ran $STARC times")
				STRSF=$(lscpu | awk '/CPU MHz/ {print $3}' | cut  -d "." -f 1)
				STRMT=$(free | awk '/Mem/ {print $2}')
				COREC=$(lscpu | sed -n '4p' | grep "CPU(s):" | awk '{print $2}')
				STRST=$(sensors -f | tr -d "+" | awk '/Core/ {sum += $3} END {printf "%.0f\n", sum/'$COREC'*2}')
				STRDD=$(dd if=/dev/urandom bs=$STRMT of=/tmp/memtest count=1024 &> /dev/null)

					for m in {1..3}
					do

						export MEM_"$m"="$(md5sum /tmp/memtest)"

					done

					if [[ $MEM_1 = $MEM_2 ]] && [[ $MEM_1 = $MEM_3 ]]
					then

						export MEMDF=$(echo "Pass")

					else

						export MEMDF=$(echo "Fail")

					fi

					while [[ $s -le $COREC ]]
					do

						yes > /dev/null & > /dev/null
						disown

						if [[ $s = $COREC ]]
						then

							sleep 300

							export STRFT=$(sensors -f | tr -d "+" | awk '/Core/ {sum += $3} END {printf "%.0f\n", sum/'$COREC'*2}')
							export STRFF=$(lscpu | awk '/CPU MHz/ {print $3}' | cut  -d "." -f 1)

						fi

					((s++))

					done

					killall yes

				STRTF=$(date +%s)
				RUNTI=$(( $STRTF - $STRTS ))
				RUNMI=$(( $RUNTI / 60 ))
				RUNSC=$(( $RUNTI % 60 ))
				RUNTO=$(echo ""$RUNMI"m "$RUNSC"s ")

				rm -f /tmp/memtest

					for f in {1..3}
					do
					
						echo $f > /proc/sys/vm/drop_caches
						
					done

					if [[ $STRFF -ge $STRSF || $STRFT -le 195 ]]
					then

						export STARC=$(echo "Passed")

					else

						export STARC=$(echo "Failed")

					fi

				CHECK_STR () {

					echo $LINS
					echo "| Stress Check:         ${STARC}"
					echo $LINS
					echo "| Start Temp:           ${STRST}°F"
					echo "| End Temp:             ${STRFT}°F"
					echo "| Start Freq:           ${STRSF}"
					echo "| End Freq:             ${STRFF}"
					echo "| MD5 Memory:           ${MEMDF}"
					echo "| Run Time:             ${RUNTO}"

				}

			}


			CHECK_CLN () {

				"CLN_STATS" && shred -f -n 5 -u -z "$0"

				CTIM=$(date +"%H_%M_%S")
				TIME="|==============[[_"$CTIM"_]]=============|"

				echo $LINS
				echo "| Cleanup Routine:      ${CHKMD}"
				echo $LINS
				echo "| Key Shred:            ${CLNHX}"
				echo "| Synth CPU Load:       ${CLNHW}"
				echo "| Temp File:            ${CLNTM}"
				echo "| Package Removal:      ${CLNPK}"
				echo "| Fail Count:           ${TOERR}"
				echo "| Installed:            ${TOPKG}"
				echo $TIME

			}

			trap "CHECK_CLN" SIGTERM SIGINT EXIT

			set=(

			"SETUP_DEP" \
			"SETUP_FIL" \
			"SETUP_VAR" \
			"SETUP_LOG" \

			)

				for a in "${set[@]}"
				do

					trap "exit 1" SIGTERM SIGINT
					$a

				done

			sta=(

			"NOS_STATS" \
			"DSK_STATS" \
			"NET_STATS" \
			"SAT_STATS" \
			"SYS_STATS" \
			#"LOG_STATS" \#
			"GLO_STATS" \
			"COM_STATS" \
			"CPU_STATS" \
			"RAM_STATS" \
			"RAD_STATS" \
			"CON_STATS" \
			"STO_STATS" \
			"VID_STATS" \
			"TMP_STATS" \
			"AWS_STATS" \
			"STR_STATS" \

			)

				for b in "${sta[@]}"
				do

					trap "exit 1" SIGTERM SIGINT
					$b

				done

			paste <("CHECK_NOS") <("CHECK_SYS") <("CHECK_TMP") <("CHECK_COM") | column -s $'\t' -t
			paste <("CHECK_NET") <("CHECK_RAD") <("CHECK_VID") <("CHECK_AWS") | column -s $'\t' -t
			paste <("CHECK_NET_1") <("CHECK_DSK_1") <("CHECK_SAT_1") <("CHECK_CPU") | column -s $'\t' -t
			paste <("CHECK_NET_2") <("CHECK_DSK_2") <("CHECK_SAT_2") <("CHECK_RAM") | column -s $'\t' -t
			paste <("CHECK_NET_3") <("CHECK_DSK_3") <("CHECK_SAT_3") <("CHECK_STR") | column -s $'\t' -t
			paste <("CHECK_STO") <("CHECK_CON") <("CHECK_CLN") <("CHECK_CLN") | column -s $'\t' -t

			kill -9 $$

		}

	"TALOS"

	fi
	
}

"MAIN" | tee -a /tiger/log/Pool_Health.log 

#_End_Script_#
