# MmapDiskImages

mmap虚拟内存映射
==============

主要功能点:<br>
---------
将磁盘上的image映射到虚拟内存、大大提高保存在disk里的image的渲染速度<br>

主要技术点:<br>
-------------
1. 将disk中队的image映射到虚拟内存<br>
2. 缓存image的时候进行了解码并且处理了字节对齐的问题、避免渲染image的时候内核再对其进行copy操作<br>

弊端:<br>
--------
1. mmap的时候会有一定的内存占用<br>
2. 缓存到沙盒中的image比较大、占用存储空间较大。<br>
