---
layout: post
title: Java8+ HashMap 扩容时重新分配节点核心逻辑
date: 2025-10-18 20:00:00 +0800
categories: 算法
---

![Java8 HashMap resize rehashing](/assets/images/java8-rehash.webp)

这张图展示的是 Java 8 中 `HashMap` 扩容（resize）时，重新分配（rehash）节点的核心逻辑。

这是一个非常巧妙的设计，它极大地优化了扩容效率。

### 核心思想：“高低位”拆分

在 Java 8 之前，`HashMap` 扩容时，需要重新计算每个节点在新哈希表中的位置（`hash & (newCapacity - 1)`），这是一个相对耗时的过程。

Java 8 利用了一个巧妙的特性：**`HashMap` 的容量（Capacity）永远是 2 的幂次方。**

当扩容时，容量会翻倍：`newCapacity = oldCapacity * 2`。

这带来一个关键的二进制特性：

1. 假设旧容量 `oldCap` 是 16 (二进制 `0001 0000`)。

      * 旧的索引计算是 `hash & (16 - 1)`，即 `hash & 15` (二进制 `0000 1111`)。这等于取 `hash` 值的**低 4 位**。

2. 那么新容量 `newCap` 就是 32 (二进制 `0010 0000`)。

      * 新的索引计算是 `hash & (32 - 1)`，即 `hash & 31` (二进制 `0001 1111`)。这等于取 `hash` 值的**低 5 位**。

对比二者，你会发现，一个节点在扩容后的新索引，**要么和旧索引一样，要么是 "旧索引 + oldCapacity"**。

决定这一切的，就是 `hash` 值中新多出来的那一位（在 `oldCap` 位置上的那一位，我们称之为“第 5 位”）。

* 如果这一位是 **0**，`hash & 31` 的结果和 `hash & 15` **完全一样**。
* 如果这一位是 **1**，`hash & 31` 的结果会比 `hash & 15` 多出一个 `16` (即 `oldCap`)。

而图中代码 `(e.hash & oldCap) == 0` 正是在做这个判断！

* `oldCap` 在这里是 16 (二进制 `0001 0000`)。
* `e.hash & oldCap` 就是在取 `hash` 值的“第 5 位”。
* 如果 `(e.hash & oldCap) == 0`，说明这一位是 0，**节点位置不变**。
* 如果 `(e.hash & oldCap) != 0`，说明这一位是 1，**节点新位置 = j + oldCap**。

-----

### 逐行代码解释

这段代码的上下文是：它正在遍历旧哈希表（`oldTab`）在索引 `j` 处的一个桶（bucket）。这个桶可能是一个链表（或红黑树）。

```java
// ... 外层有一个 for 循环，遍历 oldTab[j] ...
Node<K,V> e; // e 是当前遍历到的节点
// ...
else { // preserve order (这是处理链表的情况)
    Node<K,V> loHead = null, loTail = null; // “低位”链表头尾，给位置不变的节点
    Node<K,V> hiHead = null, hiTail = null; // “高位”链表头尾，给位置改变的节点
    Node<K,V> next;
    do {
        next = e.next; // 暂存下一个节点

        // 这就是核心判断！
        if ((e.hash & oldCap) == 0) {
            // == 0，说明新索引和旧索引 j 相同
            if (loTail == null)
                loHead = e; // 第一个“低位”节点
            else
                loTail.next = e; // 将 e 追加到“低位”链表的末尾
            loTail = e; // 更新“低位”链表的尾指针
        }
        else {
            // != 0，说明新索引是 j + oldCap
            if (hiTail == null)
                hiHead = e; // 第一个“高位”节点
            else
                hiTail.next = e; // 将 e 追加到“高位”链表的末尾
            hiTail = e; // 更新“高位”链表的尾指针
        }
    } while ((e = next) != null); // 循环，直到遍历完 oldTab[j] 上的整个链表

    // 遍历完成后，oldTab[j] 上的旧链表被拆分成了 lo 和 hi 两个新链表

    if (loTail != null) {
        loTail.next = null; // 终止“低位”链表
        newTab[j] = loHead; // 不需要换位置的节点们：将“低位”链表（loHead）放到新哈希表的 j 位置
    }
    if (hiTail != null) {
        hiTail.next = null; // 终止“高位”链表
        newTab[j + oldCap] = hiHead; // 需要换位置的节点们, 直接下标+老数组大小：将“高位”链表（hiHead）放到新哈希表的 j + oldCap 位置
    }
}
```

### 总结

这段代码的精妙之处在于：

1. **无需重新计算 Hash**：它没有对每个节点都做一次 `hash & (newCap - 1)` 的完整计算。
2. **一次遍历，拆成两条链**：它只遍历了 `oldTab[j]` 上的链表一次，就巧妙地通过 `(e.hash & oldCap)` 这个简单的位运算，将原链表拆分成了两个新的链表。
3. **直接放置**：拆分后，`lo` 链表直接放在新表的 `j` 位置，`hi` 链表直接放在新表的 `j + oldCap` 位置。
4. **保持顺序**：通过 `loTail` 和 `hiTail` 在尾部追加节点，它还保持了原链表中节点的相对顺序（`preserve order`）。

这个优化将原先 `O(N)` 的重新计算（N是所有元素）变成了 `O(n)` 的拆分（n 是单个桶中的元素），并且位运算的成本极低，极大地提升了 `HashMap` 的扩容性能。
