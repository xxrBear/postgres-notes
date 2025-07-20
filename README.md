<div align="center">
<img src="https://cdn.jsdelivr.net/gh/xxrBear/image//Hugo/202505152126346.png" height="200"/>
</div>

- [安装数据库](#安装数据库)
- [SQL 风格](#sql-风格)
- [查看运行参数](#查看运行参数)
- [自定义配置参数](#自定义配置参数)
- [常用数据类型](#常用数据类型)
- [常用函数](#常用函数)
- [连接语句](#连接语句)


## 安装数据库

推荐使用官方安装包，前往[下载页](https://www.postgresql.org/download/)下载对应系统的安装包

## SQL 风格
<details>
<summary>点击展开</summary>
</br>
  
**关键字大写，字段/表名小写**

```sql
SELECT id, name, created_at
FROM users
WHERE status = 'active';
```

**每个子句独占一行，逻辑清晰**

```sql
SELECT id, name, email
FROM customers
WHERE created_at >= '2024-01-01'
  AND status = 'active'
ORDER BY created_at DESC;
```


**缩进对齐（2 或 4 空格，保持统一）**

```sql
SELECT
    order_id,
    customer_id,
    total_amount
FROM
    orders
WHERE
    status = 'completed';
```


**表别名统一风格，建议简洁有意义**

```sql
SELECT o.order_id, c.name
FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

不推荐使用 `a`, `b`, `t1`, `t2` 这类无意义的别名。


**使用显式 JOIN，避免隐式连接**

推荐：

```sql
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.id;
```

不推荐（隐式连接）：

```sql
SELECT *
FROM orders o, customers c
WHERE o.customer_id = c.id;
```


**WHERE 子句对齐 AND/OR**

```sql
WHERE
    type = 'book'
    AND created_at >= '2024-01-01'
    AND (
        price >= 100 OR discount IS NOT NULL
    )
```


**复杂查询可分块注释**

```sql
-- 获取订单及客户信息
SELECT o.id, o.total, c.name
FROM orders o
JOIN customers c ON o.customer_id = c.id
WHERE o.status = 'completed';
```
</details>

## 查看运行参数
<details>
<summary>点击展开</summary>
</br>
在 PostgreSQL 中，SHOW 命令用于 查看当前数据库的运行时参数配置

**性能与内存相关**

```sql
SHOW shared_buffers;                 -- PostgreSQL 用于缓存数据块的内存
SHOW work_mem;                       -- 每个排序、哈希操作的内存大小
SHOW maintenance_work_mem;          -- 维护操作（如VACUUM, CREATE INDEX）使用的内存
SHOW effective_cache_size;          -- 操作系统文件缓存的估计值
SHOW random_page_cost;              -- 非顺序读取一个页面的成本估计
```

**并发与并行控制**

```sql
SHOW max_connections;                -- 最大连接数
SHOW max_worker_processes;          -- 最大后台工作进程数
SHOW max_parallel_workers;          -- 最大并行工作者数
SHOW max_parallel_workers_per_gather; -- 每次并行Gather的最大并行工作者数
SHOW max_parallel_maintenance_workers; -- CREATE INDEX等使用的并行工作者数
```

**WAL日志与检查点**

```sql
SHOW wal_level;                     -- 日志级别（minimal / replica / logical）
SHOW wal_buffers;                   -- WAL缓冲区大小
SHOW checkpoint_completion_target;  -- 检查点完成目标时间
SHOW min_wal_size;                  -- 最小WAL文件总大小
SHOW max_wal_size;                  -- 最大WAL文件总大小
```

**日志记录相关**

```sql
SHOW log_destination;                -- 日志输出目标（stderr, csvlog等）
SHOW logging_collector;             -- 是否启用日志收集器
SHOW log_min_duration_statement;    -- 执行超过指定时间的SQL将被记录
SHOW log_directory;                 -- 日志文件存放目录
SHOW log_filename;                  -- 日志文件名称模板
```


**编码、时区、语言**

```sql
SHOW client_encoding;               -- 客户端字符集编码
SHOW server_encoding;               -- 服务器端编码
SHOW lc_collate;                    -- 排序规则
SHOW lc_ctype;                      -- 字符分类
SHOW TimeZone;                      -- 当前数据库时区
```

**其它实用参数**

```sql
SHOW default_statistics_target;     -- 默认统计目标，影响ANALYZE粒度
SHOW temp_buffers;                  -- 每个连接分配的临时缓存区
SHOW enable_seqscan;                -- 是否启用顺序扫描（可用于调优）
SHOW synchronous_commit;            -- 是否同步提交（影响性能与可靠性）
```


**一次性查看多个参数**

```sql
SHOW ALL LIKE 'max_%';
SHOW ALL LIKE '%buffer%';
SHOW ALL LIKE '%log%';
```
</details>

## 自定义配置参数

<details>
<summary>点击展开</summary>
</br>
PostgreSQL 安装后的默认配置通常并不适合生产环境的高性能需求，默认配置为了兼容低配置机器（如 512MB 内存的老机器），保守设置

推荐使用：[PGTune](https://pgtune.leopard.in.ua/)

输入参数，直接复制配置参数

查看PG服务配置文件所在位置
```sql
SHOW config_file;
```

修改配置文件并保存，重启数据库
</details>

## 常用数据类型
<details>
<summary>
点击展开    
</summary>
</br>

 **数值类型**

| 类型                            | 描述                                     |
| ------------------------------- | ---------------------------------------- |
| `smallint`                      | 2 字节整数（-32,768 \~ 32,767）          |
| `integer` 或 `int`              | 4 字节整数（-2^31 \~ 2^31-1）            |
| `bigint`                        | 8 字节整数（-2^63 \~ 2^63-1）            |
| `decimal(p,s)` / `numeric(p,s)` | 高精度定点数                             |
| `real`                          | 4 字节浮点数                             |
| `double precision`              | 8 字节浮点数                             |
| `serial`                        | 自增 4 字节整数（等价于 int + sequence） |
| `bigserial`                     | 自增 8 字节整数                          |

**字符类型**

| 类型         | 描述                          |
| ------------ | ----------------------------- |
| `char(n)`    | 固定长度字符串，不足会补空格  |
| `varchar(n)` | 可变长度字符串，最大 n 个字符 |
| `text`       | 可变长度字符串，无长度限制    |

**日期与时间类型**

| 类型          | 描述                                       |
| ------------- | ------------------------------------------ |
| `timestamp`   | 无时区时间戳                               |
| `timestamptz` | 带时区的时间戳（timestamp with time zone） |
| `date`        | 日期（YYYY-MM-DD）                         |
| `time`        | 时间（无日期）                             |
| `interval`    | 时间间隔（如 "2 days 3 hours"）            |

 **布尔类型**

| 类型      | 描述                    |
| --------- | ----------------------- |
| `boolean` | `TRUE`、`FALSE`、`NULL` |

**枚举类型**

你可以自定义枚举：

```sql
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
```

**数组类型**

```sql
-- 整数数组
integer[];
text[]; 
-- 多维数组也支持
```

**JSON / JSONB 类型**

| 类型    | 描述                            |
| ------- | ------------------------------- |
| `json`  | 文本形式存储 JSON，不支持索引   |
| `jsonb` | 二进制 JSON，支持索引，推荐使用 |

**UUID 类型**

| 类型   | 描述                    |
| ------ | ----------------------- |
| `uuid` | 通用唯一标识符（128位） |

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid()
);
```

**网络相关类型**

| 类型      | 描述               |
| --------- | ------------------ |
| `inet`    | IPv4 或 IPv6 地址  |
| `cidr`    | 网络地址（含掩码） |
| `macaddr` | MAC 地址           |

**几何类型**

| 类型      | 描述           |
| --------- | -------------- |
| `point`   | 点 (x, y)      |
| `line`    | 无限直线       |
| `lseg`    | 线段           |
| `box`     | 矩形框         |
| `circle`  | 圆形           |
| `path`    | 路径（开或闭） |
| `polygon` | 多边形         |

**高级类型（可选）**

* `tsvector`, `tsquery`：全文搜索
* `money`：货币类型（但建议用 numeric）
* `bit`, `bit varying`：位串（少见）



**查询所有数据类型**

```sql
-- 查看所有已注册的类型（系统 + 自定义）
SELECT typname, typtype, typcategory FROM pg_type;
```

</details>


## 常用函数

<details>
<summary>点击展开</summary>
</br>

**字符串函数**

长度、截取、拼接
```sql
SELECT LENGTH('hello');       -- 5  获取字符串长度

SELECT LEFT('PostgreSQL', 4); -- 'Post'  获取左侧 4 个字符

SELECT RIGHT('PostgreSQL', 4);-- 'SQL'   获取右侧 4 个字符

SELECT CONCAT('Hello', ' ', 'World'); -- 'Hello World'  字符串拼接

SELECT 'Hello' || ' World' as hello;  -- 'Hello World'  另一种拼接方式
```

大小写转换
```sql
SELECT UPPER('hello'); -- 'HELLO' 转换为大写

SELECT LOWER('HELLO'); -- 'hello' 转换为小写

SELECT INITCAP('hello world'); -- 'Hello World'  每个单词首字母大写
```

去空格
```sql
SELECT TRIM('  hello  ');  -- 'hello'  去掉两端空格

SELECT LTRIM('  hello');   -- 'hello'  去掉左侧空格

SELECT RTRIM('hello  ');   -- 'hello'  去掉右侧空格
```

查找与替换
```sql
SELECT POSITION('SQL' IN 'PostgreSQL'); -- 9  查找子字符串位置

SELECT REPLACE('hello world', 'world', 'PostgreSQL'); -- 'hello PostgreSQL' 替换

SELECT SUBSTRING('PostgreSQL' FROM 5 FOR 3); -- 'gre'  截取子字符串
```

**日期和时间**
```sql
SELECT NOW();          -- 获取当前时间戳

SELECT CURRENT_DATE;   -- 获取当前日期

SELECT CURRENT_TIME;   -- 获取当前时间

SELECT CURRENT_TIMESTAMP; -- 获取当前时间戳

SELECT EXTRACT(YEAR FROM NOW()); -- 获取当前年份

SELECT DATE_PART('month', NOW()); -- 获取当前月份

SELECT AGE(CURRENT_DATE, '2023-12-21'); -- 计算年月日差

SELECT DATE_TRUNC('month', NOW()); -- 截断到月份 '2025-03-01 00:00:00'

SELECT NOW() + INTERVAL '5 days'; -- 计算未来 5 天的日期

SELECT NOW() - INTERVAL '1 hour'; -- 计算 1 小时前的时间

SELECT TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS'); -- 格式化日期
```

**数学**
```sql
SELECT ABS(-10);       -- 10  绝对值

SELECT CEIL(4.3);      -- 5   向上取整

SELECT FLOOR(4.9);     -- 4   向下取整

SELECT ROUND(4.567, 2);-- 4.57  取小数

SELECT POWER(2, 3);    -- 8   幂运算 (2^3)

SELECT SQRT(16);       -- 4   开平方

SELECT RANDOM();       -- 生成 0~1 之间的随机数

SELECT PI();           -- 3.141592653589793  圆周率

SELECT EXP(1);         -- 2.718281828459045  e 的指数

SELECT LOG(10);        -- 2.302585092994046  以 e 为底的对数
```

**条件判断**
```sql
SELECT COALESCE(NULL, 'default'); -- 'default'  返回第一个非 NULL 值

SELECT NULLIF(10, 10); -- NULL  如果两个值相等，则返回 NULL

SELECT CASE 
    WHEN age < 18 THEN '未成年'
    WHEN age BETWEEN 18 AND 60 THEN '成年'
    ELSE '老年'
END AS age_group FROM people;
```

**数组**
```sql
SELECT ARRAY[1, 2, 3] || ARRAY[4, 5]; -- {1,2,3,4,5}  数组合并

SELECT ARRAY_APPEND(ARRAY[1, 2], 3);  -- {1,2,3}  增加

SELECT ARRAY_REMOVE(ARRAY[1, 2, 3], 2); -- {1,3}  移除元素

SELECT UNNEST(ARRAY[1,2,3]); -- 拆分数组
```

**Json**
```sql
SELECT '{"name": "Alice", "age": 25}'::json->>'name'; -- 'Alice'

SELECT '{"a": {"b": "c"}}'::jsonb #>> '{a,b}'; -- 'c'  访问 JSON 数据

SELECT jsonb_build_object('name', 'Bob', 'age', 30); -- 生成Json数据

SELECT jsonb_array_elements('[1,2,3]'::jsonb); -- 拆解 JSON 数组
```

**序列和 ID 处理**
```sql
-- 创建序列
CREATE SEQUENCE my_sequence
    START WITH 1      -- 起始值
    INCREMENT BY 1    -- 每次递增的值
    MINVALUE 1        -- 最小值
    MAXVALUE 1000     -- 最大值（可选）
    CYCLE;            -- 达到最大值后是否循环（可选）

SELECT nextval('my_sequence'); -- 获取下一个序列值

SELECT currval('my_sequence'); -- 获取当前序列值

SELECT setval('my_sequence', 100); -- 设置序列当前值

DROP SEQUENCE my_sequence; -- 删除
```

**实用函数**
```sql
SELECT MD5('password'); -- 计算 MD5 哈希值

SELECT PG_SLEEP(5); -- 让查询暂停 5 秒

SELECT VERSION(); -- 获取 PostgreSQL 版本

SELECT PG_SIZE_PRETTY(PG_DATABASE_SIZE('mydb')); -- 获取数据库大小
```

**聚合函数**

```sql
SELECT COUNT(*) FROM users; -- 统计行数

SELECT MAX(salary) FROM employees; -- 最高工资

SELECT MIN(salary) FROM employees; -- 最低工资

SELECT AVG(salary) FROM employees; -- 平均工资

SELECT SUM(salary) FROM employees; -- 工资总和

SELECT STRING_AGG(name, ', ') FROM users; -- 拼接字符串
```
</details>

## 连接语句 
<details>
<summary>
点击展开    
</summary>
</br>

**内连接**
在 PostgreSQL 中，INNER JOIN 的行为如下：

> 只返回两个表中 满足 ON 条件 的匹配行

创建表
```sql
CREATE TABLE department (
    id SERIAL PRIMARY KEY,
    name TEXT
);

CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    name TEXT,
    dept_id INT
);

```

插入数据
```sql
INSERT INTO department (name) VALUES ('IT'), ('HR');

INSERT INTO employee (name, dept_id) VALUES
  ('Alice', 1),
  ('Bob', 2),
  ('Carol', NULL),
  ('David', 3);
```

| employee.id | name  | dept_id |
| ----------- | ----- | ------- |
| 1           | Alice | 1       |
| 2           | Bob   | 2       |
| 3           | Carol | NULL    |
| 4           | David | 3       |

| department.id | name |
| ------------- | ---- |
| 1             | IT   |
| 2             | HR   |

执行内连接
```sql
SELECT e.name AS employee_name, d.name AS department_name
FROM employee e
INNER JOIN department d
ON e.dept_id = d.id;
```

结果
| employee\_name | department\_name |
| -------------- | ---------------- |
| Alice          | IT               |
| Bob            | HR               |



</details>
