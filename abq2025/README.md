# Abaqus 2025镜像

## 简介

Abaqus 2025镜像的制作过程与Abaqus 2024几乎完全相同，唯一的区别是需要设置环境变量 `LANG=C.UTF-8`（体现在step-3的Dockerfile中），否则Abaqus CAE会因为编码问题而启动失败。

顺便推荐阅读一下[Abaqus与License Server分离部署方案](../abq_license_separated/README.md)，也许有帮助。

## 使用方法

与Abaqus 2024镜像使用方法完全相同。

## 补充说明

我在某些环境下测试Abaqus 2025镜像时发现了一个新问题。这个问题在2021和2024版本未遇到，也并不是在所有环境下都会出现。

当以默认的`mp_mode=mpi`模式多核运行Abaqus/Explicit，且cpus>= 3时，作业可能会失败，Job-1.log会出现“KILLED BY SIGNAL: 7 (Bus error)”的错误。其原因在于容器共享内存不足，导致MPI通信失败。

解决方法：在创建容器时加入 `--shm-size=1g`（默认是 64m）以增大共享内存，或使用 `--ipc=host` 来使用宿主机的IPC命名空间。

<details>
<summary>点击展开查看Job-1.log相关报错信息</summary>

```log
Begin Abaqus/Explicit Analysis
Wed Jun  3 02:32:34 2026
Run explicit

*** ABAQUS/explicit rank 0 terminated by signal 7

*** ERROR CATEGORY:  EXPLICIT

===================================================================================
=   BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES
=   RANK 0 PID 1645 RUNNING AT 038657c6d1b4
=   KILLED BY SIGNAL: 7 (Bus error)
===================================================================================

===================================================================================
=   BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES
=   RANK 1 PID 1646 RUNNING AT 038657c6d1b4
=   KILLED BY SIGNAL: 9 (Killed)
===================================================================================

===================================================================================
=   BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES
=   RANK 2 PID 1647 RUNNING AT 038657c6d1b4
=   KILLED BY SIGNAL: 9 (Killed)
===================================================================================

===================================================================================
=   BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES
=   RANK 3 PID 1648 RUNNING AT 038657c6d1b4
=   KILLED BY SIGNAL: 9 (Killed)
===================================================================================
```

</details>

## 镜像制作过程

### 1. 搭建Abaqus安装环境

准备安装包2025.AM_SIM_Abaqus_Extend.AllOS，将整个安装包的权限都设成777。无需对Abaqus 2025安装包的内容做任何修改。

此外，备好ubuntu:20.04镜像。

先通过step-1-preliminary里的Dockerfile建立abq2025-tmp1镜像。

```bash
cd /path/to/abq2025/step-1-preliminary
docker build -t abq2025-tmp1 .
```

然后创建一个abq2025-tmp1的容器abq2025-tmp1-1，把安装包到容器root目录（我的安装包放在 `/root/abaqus-docker/abq2025/AM_SIM_Abaqus_Extend.AllOS`）：

```bash
docker run -d --mount type=bind,source=/root/abaqus-docker/abq2025/AM_SIM_Abaqus_Extend.AllOS,target=/root/AM_SIM_Abaqus_Extend.AllOS --name abq2025-tmp1-1 abq2025-tmp1
```

### 2. 安装Abaqus 2025

进入容器安装Abaqus 2025。

Abaqus 2025安装脚本还是会检查系统，Ubuntu不满足要求，但是2025和2024版本一样，可以通过在安装前定义环境变量

```bash
export DSY_Skip_CheckPrereq=1
```

来让安装脚本跳过系统检查。

开始安装

```bash
/root/AM_SIM_Abaqus_Extend.AllOS/1/StartTUI.sh
```

安装的时候还是选5和6，也就是SIMULIA Established Products两个。去掉7，不安装Isight。不用专门选上4 [ ] FLEXnet License Server，之后会单独安装。

安装组件还是选12345。

Abaqus 2025安装程序会自动检测安装介质路径，不需要像之前版本一样在安装过程中输入路径了。

遇到安装license server就选3，skip。

之后一路确认，就装完了。

Abaqus 2025根据ABQ_USUB_GFORTRAN环境变量决定是否使用gfortran。

装完退出容器，打包。

```bash
docker commit abq2025-tmp1-1 abq2025-tmp2
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

然后进入step-3-license，用里面的Dockerfile新建镜像。

```bash
cd /path/to/abq2025/step-3-license
docker build -t abq2025-tmp3 .
```

### 4. Squash镜像

```bash
docker-squash -f $(($(docker history abq2025-tmp3 | wc -l | xargs)-1)) -t abq2025:latest abq2025-tmp3
```
