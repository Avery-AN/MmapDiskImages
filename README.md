# MmapDiskImages
将磁盘上的image映射到虚拟内存、大大提高保存在disk里的image的渲染速度

主要技术点:
(1)将disk中队的image映射到虚拟内存
(2)缓存image的时候进行了解码并且处理了字节对齐的问题、避免渲染image的时候内核再对其进行copy操作

缺点是缓存到沙盒中的image比较大、占用存储空间较大。
