# Abaqus与License Server分离部署方案

我制作的abq2021等镜像都是集成了Abaqus软件和License Server，这种集成的镜像使用起来最为方便。不过，还可以采用另一种架构，把Abaqus和License Server分开。

分离架构包含两个容器，一个只有Abaqus软件，另一个只有License Server。通过Docker Network让它们互相通信。这种架构的好处是可以在不同版本的Abaqus之间共享同一个License Server。

比如，我现在想要使用Abaqus 2024。由于Abaqus 2024需要高版本的glibc，而CentOS 7的glibc版本太低，因此无法基于CentOS 7镜像安装。为此，我可以基于Ubuntu 20.04这种包含高版本glibc的镜像来安装Abaqus 2024。可惜的是，在Ubuntu镜像上安装License Server比较麻烦（需要安装lsb-core）。不过，基于CentOS 7安装License Server却非常简单。这一矛盾就可以通过分离架构来解决，用基于CentOS 7的abq2021镜像中集成的License Server来为基于Ubuntu 20.04的abq2024提供服务。

具体步骤如下：

1. 先建一个 docker network：

   ```bash
   docker network create abaqus-network
   ```

2. 创建一个abq2021容器，只用它的License Server（我的abq2021镜像里的License是27800端口）：

   ```bash
   docker run -d --name abaqus-license --network abaqus-network -p 27800:27800 abq2021
   ```

3. 再建一个装有Abaqus 2024的容器，假设镜像名为 `abq2024-nolic`：

   ```bash
   docker run -d --name abq2024-compute --network abaqus-network --mount type=bind,source=/home,target=/home abq2024-nolic
   ```

4. 进到 `abq2024-compute` 容器，在 `/usr/SIMULIA/EstProducts/2021/linux_a64/SMA/site/EstablishedProductsConfig.ini` 最后加上许可证配置，变成这样

    ```ini
    [EstablishedProducts]
    LICENSE_SERVER_TYPE=flex
    FLEX_LICENSE_CONFIG=27800@abaqus-license
    ```

   **注意**这里是的主机名是abaqus-license而不是localhost，因为License Server在另一个容器中运行。

配置完，就能正常使用Abaqus 2024了。
