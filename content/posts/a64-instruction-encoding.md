+++
title = "A64指令集編碼"
author = ["fuloido"]
date = 2025-03-15T00:00:00+08:00
lastmod = 2025-03-15T17:47:31+08:00
tags = ["VM", "ASM", "ARM"]
draft = false
+++

最近在做 Aarch64 架構的虛擬機，在此分享一下 A64 的指令編解碼。

儘管 A64/A32 指令集是由若干 _FEAT_XXX_ 組成的，但 Arm 還是將其分為了若干類以便於拓展和編解碼。大概可以分為：

1.  基本指令集
2.  浮點數和 SIMD 指令集
3.  向量指令集
4.  矩陣指令集

在編解碼時由指令了 **[25:28]** 位決定其分類，具體的分類見下表：

| Instr[28:25]           | 對應指令集分類                                             |
|------------------------|-----------------------------------------------------|
| 0b0000 (Instr[31] = 0) | 保留                                                       |
| 0b0000 (Instr[31] = 1) | 矩陣指令集 (SME)                                           |
| 0b0010                 | 向量指令集 (SVE)                                           |
| 0b100x                 | 數據通路 (Data Processing)：立即數類                       |
| 0b101x                 | 分支指令、異常生成 (Exception Generating)、系統指令 (System instruction) |
| 0bx101                 | 數據通路 (Data Processing)：寄存器類                       |
| 0bx111                 | 數據通路 (Data Processing)：浮點數以及 SIMD 指令集         |
| 0bx1x0                 | 內存加載和儲存 (Loads and Store)                           |

下面簡單分享一下基本指令集和浮點、SIMD 指令集的編解碼規則，後續有機會分享一下 SVE 以及 SME 指令集的編解碼。


## 數據通路 - 寄存器類 {#數據通路-寄存器類}

這一類指令類型主要涵蓋了：

1.  **邏輯運算**: 比如 _AND_, _ORR_ 等。
2.  **算數運算**: 比如 _ADD_, _ADC_, _SBC_ 等。
3.  **條件運算**: 比如 _CSEL_, _CCMP_ 等。
4.  **其他的特殊操作**: 通常由處理器實現的 FEAT 相關，編解碼時由 **操作數** 數量區分。

具體的編碼表如下：

| Instr[28] | Instr[24:21]                       | Instr[15:10] | 相應指令分類                                         |
|-----------|------------------------------------|--------------|------------------------------------------------|
| 0         | 0b0xxx                             |              | 邏輯運算 (shifted register 類)                       |
| 0         | 0b1xx0                             |              | 加減運算 (shifted register 類)                       |
| 0         | 0b1xx1                             |              | 加減運算 (extended register 類)                      |
| 1         | 0b0000                             | 0b000000     | 加減運算 (with carry 類)                             |
| 1         | 0b0000                             | 0b001xxx     | 加減運算 (checked pointer 類，用於檢查指針運算是否超出範圍) |
| 1         | 0b0000                             | 0bx00001     | Rotate right into flags 類 (數值右旋並改變處理器的 flags) |
| 1         | 0b0000                             | 0bxx0010     | Evaluate into flags 類 (條件測試並改變處理器的conditional flags) |
| 1         | 0b0010                             | 0bxxxx0x     | 條件比較 (寄存器類)                                  |
| 1         | 0b0010                             | 0bxxxx1x     | 條件比較 (立即數類)                                  |
| 1         | 0b0100                             |              | 條件選擇 (例如 CSEL，允許根據條件標誌選擇不同的寄存器值) |
| 1         | 0b0110, Instr[28]=0, Instr[30] = 1 |              | 單源操作數數據通路                                   |
| 1         | 0b0110, Instr[28]=0, Instr[30] = 0 |              | 雙源操作數數據通路                                   |
| 1         | 0b1xxx                             |              | 三源操作數數據通路                                   |


## 數據通路 - 立即數類 {#數據通路-立即數類}

| Instr[30:29] | Instr[25:22] | 指令分類                                |
|--------------|--------------|-------------------------------------|
|              | 0b00xx       | PC 相對尋址 (PC-rel. addressing)        |
|              | 0b010x       | Add/substract                           |
|              | 0b0110       | Add/substract (with tags)，用於 **MTE** 拓展 |
|              | 0b0111       | Min/max                                 |
|              | 0b100x       | Logical                                 |
|              | 0b101x       | Move wide                               |
|              | 0b110x       | Bitfield                                |
| Not 0b11     | 0b111x       | Extract                                 |
| 0b11         | 0b111x       | 單源操作數數據通路                      |


## 內存加載和儲存 {#內存加載和儲存}

A64 有著極為獨特訪存模式以及豐富的訪存拓展，因此 Load/store 指令的數量也極為龐大。即使是基本 Load/store 指令，也有著不同的偏移量訪存模式。同時不同的特權級 (EL) 也有特定的訪存指令，而且拓展指令集也會帶來各自的訪存指令 (比如 SIMD)。因此會有一個特別上的 tag 段來進行編解碼。這裡給出相關的 Load/store 種類，而不給出具體的編解碼表。

1.  偏移量種類: 可以分為 _unsigned immediate_, _unscaled immediate_, _register offset_, _pre-indexed_, _post-indexed_ 等種類。
2.  成對加載/存儲: 比如 `LDP/STP` ，適用於 64-bit、128-bit。
3.  互斥訪存: 適用於多處理器環境中的 **同步與互斥** ，比如獨佔訪問 (`LDXR/STXR` exclusive register)、Compare and Swap (`CAS`)、Release-Compare-Write (`RCW CAS`)。
4.  內存順序保證 (_Ordered_): 這類指令確保訪存順序，通常用於內存屏障和同步機制。比如 (`STLR` store-release, `LDAPR` load-acquire)
5.  Memory Tagging: Arm 引入了 _Memory Tagging Extension (MTE)_ 機制用於內存安全檢查。比如 (`LDG/STG` load/store tags)
6.  原子操作: 比如原子加法 (`LDADD/STADD`)，原子復位 (`LDCLR/STCLR`) 等。

一些 Armv8 的 FEAT 也會引入特殊用途的訪存指令，比如 _Pointer Authentication Code_, _General Capability System_ 等。


## 分支指令、異常生成和系統指令 {#分支指令-異常生成和系統指令}

_Branches, Exception Generating, and System Instructions_ 指令集大概可以分為一下幾類並以此編解碼：

1.  **分支指令**: 包括條件、無條件分支、基於比較的分支等，同時也可以根據源操作數種類進行劃分。
2.  **異常生成指令**: 這些指令用於產生異常 (_Exception_)，以實現系統調用、調試或錯誤處理。包括： `SVC`, `HVC`, `BRK` 等等。
3.  **System Instructions (系統管理指令指令)** : 這類指令用於 <span class="underline">訪問處理器狀態 (_PSTATE_)</span> 、 <span class="underline">執行特殊操作</span> 、 <span class="underline">同步內存</span> 等。
4.  **Hints &amp; Barriers**: 在 A64 系統指一些 **影響** CPU 的行為，但不會改變程式的 **邏輯結果** 。比如 _NOP_, _WFE_ 等 Hints 指令以及 _DSB_, _DMB_ 等內存屏障指令

由於這類指令數量較多且極易和常常拓展，同時理論上不需要多少源操作數，A64 足足用了 Instr[31:29] 和 Instr[25:12] 這麼長的譯碼空間。


## 浮點數、SIMD 指令 {#浮點數-simd-指令}

總得來說，A64 的 _Scalar Floating-Pointe and Advanced SIMD_ 可以分為三大類指令:

1.  Cryptographic
2.  Advenced SIMD
3.  Floating-Point

Cryptographic 是大概分為 AES 和 SHA，並根據算法複雜性和步驟分為不同寄存器數量的指令 (如 two/three/four-register) 。

浮點數指令則分為 **Convention** 和浮點數的 **Data processing** ， _Advanced SIMD_ 則涉及一些更為復雜的數據通路及指令，比如 _across lanes_ (對整個向量求和或取最大值等)、 _table lookup_ 、 _permute_ 等
