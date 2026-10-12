# Abaqus 2022镜像

Abaqus 2022镜像的使用与Abaqus 2021完全相同，制作过程也基本相同，除了两点：

1. 从2022版本开始，许可证配置不再写入`custom_v6.env`，而是写入`EstablishedProductsConfig.ini`。
2. 我手头的Abaqus 2022安装包创建的命令是`abq`而非`abaqus`，我手动补了一个`abaqus`符号链接到`abq2022`。
