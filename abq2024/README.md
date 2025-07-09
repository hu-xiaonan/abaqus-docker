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

```plain
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

然后进入step-3-license，用里面的Dockerfile新建镜像

```bash
cd /path/to/abq2024/step-3-license
docker build -t abq2024-tmp3 .
```

### 4. Squash镜像

其实不做squash也可以正常使用，不会出现Abaqus 2021中那样的MPI报错问题。不过，为了与Abaqus 2021镜像保持一致，还是做了squash。结果squash完镜像体积反而略微增大了一点，无所谓了。

由于镜像较大，squash过程可能会超时（默认超时时间为600秒）。可以通过设置环境变量 `DOCKER_TIMEOUT` 来修改超时时间。

```bash
export DOCKER_TIMEOUT=3600
docker-squash -f $(($(docker history abq2024-tmp3 | wc -l | xargs)-1)) -t abq2024:latest abq2024-tmp3
```
