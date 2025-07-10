# Abaqus 2024镜像

## 简介

Abaqus 2024要求glibc>=2.28，而CentOS 7的glibc版本是2.17，无法满足要求。因此，我使用Ubuntu 20.04作为基础镜像制作了Abaqus 2024镜像。

由于Abaqus 2024本身比Abaqus 2021体积更大，并且为了在Ubuntu 20.04上安装Abaqus 2024需要额外安装一些依赖包，所以该镜像相比Abaqus 2021镜像体积更大，臃肿了些。

顺便推荐阅读一下[Abaqus与License Server分离部署方案](../abq_license_separated/README.md)，也许有帮助。

## 使用方法

与Abaqus 2021镜像使用方法完全相同。

## 镜像制作过程

### 1. 搭建Abaqus安装环境

安装包DS.SIMULIA.SUITE.2024.LINX64，里面最起码要有（里面有1、5、6几个子文件夹）。将整个安装包的权限都设成777。无需对Abaqus 2024安装包的内容做任何修改。

此外，备好ubuntu:20.04镜像。

先通过step-1-preliminary里的Dockerfile建立abq2024-tmp1镜像。

```bash
cd /path/to/abq2024/step-1-preliminary
docker build -t abq2024-tmp1 .
```

然后创建一个abq2024-tmp1的容器abq2024-tmp1-1，把安装包到容器root目录（我的安装包放在 `/root/abaqus-docker/abq2024/DS.SIMULIA.SUITE.2024.LINX64`）：

```bash
docker run -d --mount type=bind,source=/root/abaqus-docker/abq2024/DS.SIMULIA.SUITE.2024.LINX64,target=/root/DS.SIMULIA.SUITE.2024.LINX64 --name abq2024-tmp1-1 abq2024-tmp1
```

### 2. 安装Abaqus 2024

进入容器安装Abaqus 2024。

Abaqus 2024安装脚本还是会检查系统，Ubuntu通不过，但是2024可以通过定义环境变量

```bash
export DSY_Skip_CheckPrereq=1
```

来让安装脚本跳过系统检查，安装之前记得输入一下这句。

开始安装

```bash
/root/DS.SIMULIA.SUITE.2024.LINX64/1/StartTUI.sh
```

安装的时候还是安装5和6，也就是SIMULIA Established Products两个。去掉7，不安装Isight。不用专门选上4 [ ] FLEXnet License Server，之后会单独安装。

之后还是输入P输入路径那一套，一路确认。

路径（方便复制）

```plaintext
/root/DS.SIMULIA.SUITE.2024.LINX64/5
/root/DS.SIMULIA.SUITE.2024.LINX64/6
```

安装组件还是选12345。

遇到安装license server就选3，skip。

之后一路确认加输入路径，就装完了。

Abaqus 2024不需要修改 `lnx86_64.env` 来配置Fortran编译器，这个文件里面有个if判断，如果定义了ABQ_USUB_GFORTRAN环境变量就会使用gfortran。

装完退出容器，打包

```bash
docker commit abq2024-tmp1-1 abq2024-tmp2
```

### 3. 安装Abaqus许可证服务

如Abaqus 2021镜像制作方法，将SolidSQUAD_License_Servers拷贝到step-3-license目录中。

目录结构如下：

```plaintext
step-3-license
├── SolidSQUAD_License_Servers
│   ├── Vendors
│   ├── Windows
│   ├── install_or_update.bat
│   ├── install_or_update.sh
│   └── ...
└── Dockerfile
```

给整个SolidSQUAD_License_Servers文件夹赋予读写执行权限：

```bash
chmod -R 777 /path/to/SolidSQUAD_License_Servers
```

然后进入step-3-license，用里面的Dockerfile新建镜像

```bash
cd /path/to/abq2024/step-3-license
docker build -t abq2024-tmp3 .
```

**注：** 许可证服务器运行依赖LSB。在CentOS 7镜像中已自带该组件，但在Ubuntu 20.04中需要手动安装，这也是为什么在step-1的Dockerfile中安装了 `lsb-core` 包。如果未安装LSB，许可证服务器可以正常安装，但无法运行，会不断重试并最终失败，其报错如下，供参考：

<details>
<summary>点击展开查看许可证服务器启动失败的详细日志</summary>

```log
> /usr/SolidSQUAD_License_Servers/Bin/lmgrd -c /usr/SolidSQUAD_License_Servers/Licenses/lmgrd_SSQ.lic

 4:29:00 (lmgrd) -----------------------------------------------
 4:29:00 (lmgrd)   Please Note:
 4:29:00 (lmgrd) 
 4:29:00 (lmgrd)   This log is intended for debug purposes only.
 4:29:00 (lmgrd)   In order to capture accurate license
 4:29:00 (lmgrd)   usage data into an organized repository,
 4:29:00 (lmgrd)   please enable report logging. Use Flexera Software LLC's
 4:29:00 (lmgrd)   software license administration  solution,
 4:29:00 (lmgrd)   FlexNet Manager, to  readily gain visibility
 4:29:00 (lmgrd)   into license usage data and to create
 4:29:00 (lmgrd)   insightful reports on critical information like
 4:29:00 (lmgrd)   license availability and usage. FlexNet Manager
 4:29:00 (lmgrd)   can be fully automated to run these reports on
 4:29:00 (lmgrd)   schedule and can be used to track license
 4:29:00 (lmgrd)   servers and usage across a heterogeneous
 4:29:00 (lmgrd)   network of servers including Windows NT, Linux
 4:29:00 (lmgrd)   and UNIX.
 4:29:00 (lmgrd) 
 4:29:00 (lmgrd) -----------------------------------------------
 4:29:00 (lmgrd) 
 4:29:00 (lmgrd) 
 4:29:00 (lmgrd) Server's System Date and Time: Tue Jul 08 2025 04:29:00 UTC
 4:29:00 (lmgrd) SLOG: Summary LOG statistics is enabled.
 4:29:00 (lmgrd) The license server manager (lmgrd) running as root:
 4:29:00 (lmgrd)        This is a potential security problem
 4:29:00 (lmgrd)        and is not recommended.
 4:29:00 (lmgrd) Can't make directory /usr/tmp/.flexlm, errno: 2(No such file or directory)
 4:29:00 (lmgrd) FlexNet Licensing (v11.14.0.0 build 183228 x64_lsb) started on 1b9d285219c4 (linux) (7/8/2025)
 4:29:00 (lmgrd) Copyright (c) 1988-2016 Flexera Software LLC. All Rights Reserved.
 4:29:00 (lmgrd) World Wide Web:  http://www.flexerasoftware.com
 4:29:00 (lmgrd) License file(s): /usr/SolidSQUAD_License_Servers/Licenses/lmgrd_SSQ.lic
 4:29:00 (lmgrd) lmgrd tcp-port 27800
 4:29:00 (lmgrd) (@lmgrd-SLOG@) ===============================================
 4:29:00 (lmgrd) (@lmgrd-SLOG@) === LMGRD ===
 4:29:00 (lmgrd) (@lmgrd-SLOG@) Start-Date: Tue Jul 08 2025 04:29:00 UTC
 4:29:00 (lmgrd) (@lmgrd-SLOG@) PID: 175
 4:29:00 (lmgrd) (@lmgrd-SLOG@) LMGRD Version: v11.14.0.0 build 183228 x64_lsb ( build 183228 (ipv6))
 4:29:00 (lmgrd) (@lmgrd-SLOG@) 
 4:29:00 (lmgrd) (@lmgrd-SLOG@) === Network Info ===
 4:29:00 (lmgrd) (@lmgrd-SLOG@) Listening port: 27800
 4:29:00 (lmgrd) (@lmgrd-SLOG@) 
 4:29:00 (lmgrd) (@lmgrd-SLOG@) === Startup Info ===
 4:29:00 (lmgrd) (@lmgrd-SLOG@) Server Configuration: Single Server
 4:29:00 (lmgrd) (@lmgrd-SLOG@) Command-line options used at LS startup: -c /usr/SolidSQUAD_License_Servers/Licenses/lmgrd_SSQ.lic 
 4:29:00 (lmgrd) (@lmgrd-SLOG@) License file(s) used:  /usr/SolidSQUAD_License_Servers/Licenses/lmgrd_SSQ.lic
 4:29:00 (lmgrd) (@lmgrd-SLOG@) ===============================================
 4:29:00 (lmgrd) Starting vendor daemons ... 
 4:29:00 (lmgrd) Started ABAQUSLM (internet tcp_port 44121 pid 176)
 4:29:00 (ABAQUSLM) FLEXnet Licensing version v11.6.1.0 build 66138 amd64_re3
 4:29:00 (ABAQUSLM) lmgrd version 11.14, ABAQUSLM version 11.6

 4:29:00 (ABAQUSLM) Server started on 1b9d285219c4 for: acp
 4:29:00 (ABAQUSLM) adams               afcv5_structural afcv5_thermal
 4:29:00 (ABAQUSLM) ams         aqua            atom
 4:29:00 (ABAQUSLM) atom_smooth available       barrier_adv2k
 4:29:00 (ABAQUSLM) barrier_aemdb_side barrier_eevc     barrier_iihs
 4:29:00 (ABAQUSLM) barrier_nhtsa       barrier_trl_fwdb_front beamSectGen
 4:29:00 (ABAQUSLM) biorid              cadporter_catia cadporter_catiav5 
 4:29:00 (ABAQUSLM) cadporter_catiav6 cadporter_flow    cadporter_ideas 
 4:29:00 (ABAQUSLM) cadporter_parasolid cadporter_proe  cae
 4:29:00 (ABAQUSLM) cae_nogui   catiav5_assoc_import catia_v6_assoc_import 
 4:29:00 (ABAQUSLM) catiav5_import      cel             cfd
 4:29:00 (ABAQUSLM) cmold               cosim_abaqus    cosim_acusolve
 4:29:00 (ABAQUSLM) cosim_direct        cosim_madymo    cosim_mpcci
 4:29:00 (ABAQUSLM) cosim_user  cosimulation    cpus
 4:29:00 (ABAQUSLM) cse         cse_token       debug
 4:29:00 (ABAQUSLM) design              dummy_hmntcs_emhf dummy_hmntcs_es2 
 4:29:00 (ABAQUSLM) dummy_hmntcs_es2re dummy_hmntcs_flexpli dummy_hmntcs_h305 
 4:29:00 (ABAQUSLM) dummy_hmntcs_h305_blst dummy_hmntcs_h350 dummy_hmntcs_h350_blst 
 4:29:00 (ABAQUSLM) dummy_hmntcs_h395 dummy_hmntcs_h395_blst dummy_hmntcs_q10 
 4:29:00 (ABAQUSLM) dummy_hmntcs_q6 dummy_hmntcs_sid2s_sblc dummy_hmntcs_sid2s_sbld 
 4:29:00 (ABAQUSLM) euler_lagrange      explicit        foundation
 4:29:00 (ABAQUSLM) geotech             gpgpu           gpus
 4:29:00 (ABAQUSLM) heart_model headform_peevc  iads
 4:29:00 (ABAQUSLM) kwlic               location        madymo
 4:29:00 (ABAQUSLM) moldflow    multiphysics    nx_assoc_import 
 4:29:00 (ABAQUSLM) noGUI               parallel        proe_assoc_import 
 4:29:00 (ABAQUSLM) safe                soliter         sph
 4:29:00 (ABAQUSLM) standard    sw_assoc_import sw_import
 4:29:00 (ABAQUSLM) viewer              world_sid       edb
 4:29:00 (ABAQUSLM) gateway             isight          products
 4:29:00 (ABAQUSLM) rtgateway   see             simflow
 4:29:00 (ABAQUSLM) simflowparallel tomee               webuser
 4:29:00 (ABAQUSLM) compst_m_cae        czone           FED_LIC_PICKPOINTS 
 4:29:00 (ABAQUSLM) TOSCA_CONVERT_ONF TOSCA_CONVERT_STL TOSCA_CONVERT_LSDYNA 
 4:29:00 (ABAQUSLM) TOSCA_CONVERT_ABQ TOSCA_CONVERT_PAM TOSCA_CONVERT_CORE 
 4:29:00 (ABAQUSLM) TOSCA_FLUID_SMOOTH TOSCA_FLUID_POST TOSCA_FLUID_PARALLEL 
 4:29:00 (ABAQUSLM) TOSCA_FLUID_CORE TOSCA_FLUID_INT_OPEN TOSCA_FLUID_INT_CCMP 
 4:29:00 (ABAQUSLM) TOSCA_FLUID_INT_FLUENT TOSCA_FLUID_SHAPE_SENS TOSCA_FLUID_TOPO_SENS 
 4:29:00 (ABAQUSLM) TOSCA_FLUID_TOPO_BASIC TOSCA_ONF2VTF        TOSCA_SMOOTH
 4:29:00 (ABAQUSLM) TOSCA_CORE  TOSCA_INT_ONF   TOSCA_INT_PERMAS 
 4:29:00 (ABAQUSLM) TOSCA_INT_MARC      TOSCA_INT_NXNASTRAN_DESKTOP TOSCA_INT_NXNASTRAN 
 4:29:00 (ABAQUSLM) TOSCA_INT_MDDESKTOP TOSCA_INT_NASTRAN TOSCA_INT_ANSYS 
 4:29:00 (ABAQUSLM) TOSCA_INT_ABAQUS TOSCA_SIZING       TOSCA_BEAD
 4:29:00 (ABAQUSLM) TOSCA_SHAPE TOSCA_TOPO      TOSCA_ADV_MORPH 
 4:29:00 (ABAQUSLM) TOSCA_ADV_TEMPERATURE TOSCA_ADV_NVH TOSCA_ADV_DURABILITY 
 4:29:00 (ABAQUSLM) TOSCA_ADV_NONLINEAR TOSCA_FLUID_PRERELEASE TOSCA_PRERELEASE 
 4:29:00 (ABAQUSLM) TOSCA_FLUID_DEV_PARTNER FED_PRODUCT_NX      FED_PRODUCT_FEMAP 
 4:29:00 (ABAQUSLM) FED_PRODUCT_ATOM FED_PRODUCT_TFLUID FED_PRODUCT_TSTRUCT 
 4:29:00 (ABAQUSLM) TOSCA_REPORT        tfluid_topo     tfluid_int_ccmp 
 4:29:00 (ABAQUSLM) tfluid_int_fluent tfluid_parallel tfluid_smooth
 4:29:00 (ABAQUSLM) safe_cmf    safe_comp       safe_fatigue
 4:29:00 (ABAQUSLM) safe_rotate safe_rubber     safe_tmf
 4:29:00 (ABAQUSLM) safe_true   safe_turbo      safe_verity
 4:29:00 (ABAQUSLM) analysis_engine developer   DMP
 4:29:00 (ABAQUSLM) Endurica_rubber Extended    firehole_composites 
 4:29:00 (ABAQUSLM) gauge_fatigue       generic         licence_creator 
 4:29:00 (ABAQUSLM) material_manipula plugins           PRODUCT_EXCITE_Fatigue 
 4:29:00 (ABAQUSLM) PRODUCT_fesafe      PRODUCT_safe4fatigue Rotate
 4:29:00 (ABAQUSLM) safe4fatigue        safe4mat        safe4materials
 4:29:00 (ABAQUSLM) signal_manipulation TMF             Token
 4:29:00 (ABAQUSLM) TrueLoad    TURBOlife       uniaxial_fatigue 
 4:29:00 (ABAQUSLM) EXTERNAL FILTERS are OFF
 4:29:00 (lmgrd) ABAQUSLM using TCP-port 44121
free(): invalid pointer
 4:29:01 (lmgrd) ABAQUSLM exited with status 0 signal = 17
 4:29:01 (lmgrd) Since this is an unknown status, license server 
 4:29:01 (lmgrd) manager (lmgrd) will attempt to re-start the vendor daemon.
 4:29:01 (lmgrd) REStarted ABAQUSLM (internet tcp_port 45413 pid 177)
 4:29:01 (ABAQUSLM) FLEXnet Licensing version v11.6.1.0 build 66138 amd64_re3
 4:29:01 (ABAQUSLM) lmgrd version 11.14, ABAQUSLM version 11.6

...... The above loop repeats many times ......
```

</details>

### 4. Squash镜像

其实不做squash也可以正常使用，不会出现Abaqus 2021中那样的MPI报错问题。不过，为了与Abaqus 2021镜像保持一致，还是做了squash。结果squash完镜像体积反而略微增大了一点，无所谓了。

由于镜像较大，squash过程可能会超时（默认超时时间为600秒）。可以通过设置环境变量 `DOCKER_TIMEOUT` 来修改超时时间。

```bash
export DOCKER_TIMEOUT=3600
docker-squash -f $(($(docker history abq2024-tmp3 | wc -l | xargs)-1)) -t abq2024:latest abq2024-tmp3
```
