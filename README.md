# MmapDiskImages
将磁盘上的image映射到虚拟内存、大大提高保存在disk里的image的渲染速度

主要技术点:
(1)将disk中队的image映射到虚拟内存
(2)缓存image的时候处理了字节对齐的问题避免渲染的时候内核再进行copy操作
