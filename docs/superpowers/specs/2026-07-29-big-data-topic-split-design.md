# 大数据主题拆分设计

## 目标

把 `wiki/大数据/大数据.md` 从单篇长文重构为一个有正文的主题总览和五篇可独立学习、可用于面试复习的专题笔记。内容必须可追溯到 `raw/Big-Data-Theory-and-Practice/`，并覆盖 Markdown 讲义之外的 PDF、PPTX、论文、示例代码和本地图示。

## 信息架构

- `大数据.md`：保留 4V、技术栈全景、学习路线和五个主题入口，作为 MOC 而不是空跳转页。
- `分布式协调与存储.md`：CAP/BASE、ZooKeeper、HDFS、HBase，以及一致性、读写路径和热点问题。
- `批处理与资源调度.md`：MapReduce、Shuffle、YARN、Spark，以及执行模型、资源隔离和性能排查。
- `SQL 分析与湖仓.md`：Hive、Parquet/ORC、Dremel、数仓分层、数据湖、Table Format 与 Iceberg。
- `消息队列与流处理.md`：Kafka、Flink、事件时间、Watermark、状态、Checkpoint 和端到端语义。
- `大数据面试与系统设计.md`：统一选型维度、回答框架、实时指标平台设计、故障排查和项目学习路线。

所有子页使用 `parent_note: "[[wiki/大数据/大数据]]"`，统一归入 `area: big-data` 与 `collection: big-data`。总览页改为 `note_type: moc`，子页为 `note_type: topic`。

## 原始资料策略

1. 保留原始 submodule 只读，不在 `raw/` 内做整理性修改。
2. 每篇专题至少引用相应的原始讲义或论文；`related_sources` 同时列出 PDF/PPTX、Markdown 和实践目录。
3. 使用 MinerU 抽取并核对代表性非 Markdown 资料：ZooKeeper PDF、MapReduce PDF、Parquet PPTX、Flink PDF 与 Lakehouse 论文 PDF。
4. 复用 raw 中有解释价值的本地图：MapReduce Shuffle、Dremel 嵌套列式编码、ETL、Lambda/Kappa 与 Bigtable 架构。

## 可视化设计

- 总览页：一张技术栈全景图和一张学习路径思维导图。
- 分布式协调与存储：CAP 决策图、HDFS 读写路径、HBase LSM 写路径，并嵌入 Bigtable 架构图。
- 批处理与资源调度：MapReduce 数据流、Spark DAG/Stage 边界和 YARN 资源层次，并嵌入原始 Shuffle 图。
- SQL 分析与湖仓：行列存对比、Parquet 层次、湖仓演进和 Iceberg 元数据树，并嵌入 Dremel 图。
- 消息队列与流处理：Kafka 分区/消费组、事件时间窗口、Checkpoint 提交链、Lambda/Kappa 对比，并嵌入 ETL 和 Lambda/Kappa 原图。
- 面试与系统设计：选型决策树、实时指标平台数据流和故障定位思维导图。
- `wiki/map.canvas`：以总览页为中心连接五篇主题页，形成可点击的 Obsidian 思维导图。

可视化优先使用 Mermaid，确保可维护、可搜索和可在 Obsidian 内渲染；原始图片只在其比重绘更能保留课程信息时嵌入。

## 导航与兼容

- `wiki/index.md` 保留“大数据”总入口，同时列出五篇专题。
- `wiki/wiki.base` 的目录过滤已经覆盖 `wiki/大数据`，只需把 `parent_note` 加入“大数据”视图列，并把总览加入 MOC 卡片视图。
- `wiki/log.md` 记录结构拆分、非 Markdown 抽取和可视化补充。
- 保持既有 `[[wiki/大数据/大数据|大数据]]` 链接有效。

## 验收

- 六篇页面均有完整 frontmatter、非空 summary 和可解析的 wikilink。
- Mermaid 围栏成对闭合，图中节点标识唯一且语法可由 Mermaid CLI 或等价解析器验证。
- Canvas JSON 合法、ID 唯一、所有边端点与文件节点有效；Base YAML 合法且公式/视图路径存在。
- QMD 同步后可分别检索五个主题；Git diff 无空白错误，submodule 指针和工作树保持干净。

