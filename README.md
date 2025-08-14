<div align="center">
    <img src="https://cdn.jsdelivr.net/gh/xxrBear/image/Hugo/202505152126346.png" height="200"/>
</div>

## 目录

| **简介**                  | **数据库基础**                | **数据库高级**            | **服务器管理**                  |
| ------------------------- | ----------------------------- | ------------------------- | ------------------------------- |
| [安装数据库](#安装数据库) | [SQL 风格](#sql-风格)         | [事务处理](#事务处理)     | [命令行工具](#命令行工具)       |
|                           | [常用数据类型](#常用数据类型) | [显示锁定](#显示锁定)     | [查看运行参数](#查看运行参数)   |
|                           | [字段约束](#字段约束)         | [触发器](#触发器)         | [修改运行参数](#自定义运行参数) |
|                           | [常用数据函数](#常用数据函数) | [存储过程](#存储过程)     | [管理数据库](#管理数据库)       |
|                           | [系统管理函数](#系统管理函数) | [模式管理](#模式管理)     |                                 |
|                           | [系统信息函数](#系统信息函数) | [表分区](#表分区)         |                                 |
|                           | [常用表达式](#常用表达式)     | [角色管理](#角色管理)     |                                 |
|                           | [窗口函数](#窗口函数)         | [行安全策略](#行安全策略) |                                 |
|                           | [视图](#视图)                 | [客户端认证](#客户端认证) |                                 |
|                           | [连接语句](#连接语句)         | [索引](#索引)             |                                 |
|                           | [权限管理](#权限管理)         | [性能提示](#性能提示)     |                                 |
|                           |                               | [功能扩展](#功能扩展)     |                                 |

## 安装数据库

推荐使用官方安装包，前往[下载页](https://www.postgres.org/download/)下载对应系统的安装包

## SQL 风格
  
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
[返回目录](#目录)


## 命令行工具

**简介**

postgres 的命令行工具是指一组用于管理 PG 数据库的命令行程序。它们功能强大、灵活、适用于日常数据库操作、维护、备份、恢复、性能调优等

**常用的命令行工具**

| 工具名称        | 作用简介                                          | 常用场景                           |
| --------------- | ------------------------------------------------- | ---------------------------------- |
| `pg_dump`       | 数据库备份工具，导出数据库为 SQL 脚本或自定义格式 | 定期备份数据库、迁移数据           |
| `pg_restore`    | 恢复备份数据到数据库                              | 还原由 `pg_dump` 生成的备份文件    |
| `createdb`      | 创建新数据库                                      | 命令行快速创建数据库               |
| `dropdb`        | 删除数据库                                        | 命令行删除数据库                   |
| `createuser`    | 创建新用户/角色                                   | 命令行添加数据库用户               |
| `dropuser`      | 删除用户/角色                                     | 删除数据库用户                     |
| `pg_ctl`        | 控制 PostgreSQL 服务器的启动、停止和重启          | 启动/停止数据库服务                |
| `pg_basebackup` | 基于流复制的备份工具                              | 实时备份，通常用于搭建复制集群     |
| `reindexdb`     | 重建数据库索引                                    | 优化索引、修复索引损坏             |
| `vacuumdb`      | 命令行运行 VACUUM 和 ANALYZE                      | 数据库维护，清理死行和更新统计信息 |
| `psql`          | 交互式查询工具                                    | 数据查询、管理数据库               |
| `pg_isready`    | 检查数据库服务是否运行                            | 监控脚本中检测数据库状态           |

**psql 示例**

`psql`的含义是 

它是 `postgres` 自带的交互式命令行客户端工具，主要用于连接和操作 PG 数据库

连接数据库

如果你和我一样使用二进制文件安装`postgres`数据库，你可以在终端中输入下面的命令
```shell
psql -U postgres -d your_db
```
然后输入你的数据库密码，如果一切都没有问题，你会看到类似以下的输出

```
用户 postgres 的口令：

psql (16.9)
输入 "help" 来获取帮助信息.

mydb=#
```
这表明你已经成功的连接上了你本地的 PG 数据库

- 常见的psql指令

| 命令             | 说明                                  |
| ---------------- | ------------------------------------- |
| `\q`             | 退出 psql                             |
| `\c [数据库名]`  | 连接/切换数据库                       |
| `\d`             | 显示当前数据库所有表                  |
| `\d [表名]`      | 显示指定表结构（列、类型、约束等）    |
| `\dt`            | 显示当前数据库所有普通表              |
| `\dv`            | 显示当前数据库所有视图                |
| `\df`            | 显示当前数据库所有函数                |
| `\l`             | 列出所有数据库                        |
| `\dn`            | 列出所有模式（schema）                |
| `\du`            | 显示所有用户/角色                     |
| `\set`           | 设置变量                              |
| `\x`             | 切换扩展显示模式（更易读表格）        |
| `\timing`        | 开启/关闭查询耗时显示                 |
| `\! [shell命令]` | 在 psql 中执行 shell 命令             |
| `\copy`          | 导入/导出表数据（类似 \copy FROM/TO） |
| `\i [文件名]`    | 执行指定 SQL 脚本文件                 |
| `\watch [秒]`    | 每隔多少秒重复执行前一条查询          |
| `\conninfo`      | 显示当前连接信息                      |


[返回目录](#目录)


## 查看运行参数
在 postgres 中，SHOW 命令用于 查看当前数据库的运行时参数配置

**性能与内存相关**

```sql
SHOW shared_buffers;                 -- postgres 用于缓存数据块的内存
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
[返回目录](#目录)

## 自定义运行参数

</br>

postgres 安装后的默认配置通常并不适合生产环境的高性能需求，默认配置为了兼容低配置机器，如 512MB 内存老机器

推荐使用：[PGTune](https://pgtune.leopard.in.ua/)

输入参数，直接复制配置参数

查看 PG 服务配置文件所在位置
```sql
SHOW config_file;
```

修改配置文件并保存，重启数据库

[返回目录](#目录)


## 常用数据类型
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

[返回目录](#目录)

## 字段约束

### 简介
postgres 中的约束，它是用来保证表数据的完整性和正确性的规则

### 常见约束类型

| 约束类型    | 说明                                       | 示例                                                                                                        |
| ----------- | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| NOT NULL    | 列值不能为空                               | CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT NOT NULL);                                             |
| UNIQUE      | 列值必须唯一，不能重复                     | ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);                                               |
| PRIMARY KEY | 唯一标识一行数据，隐含 NOT NULL 和 UNIQUE  | CREATE TABLE users (id SERIAL PRIMARY KEY, name TEXT);                                                      |
| FOREIGN KEY | 外键约束，保证引用的列值在另一个表中存在   | sql CREATE TABLE orders (order_id SERIAL PRIMARY KEY, user_id INT REFERENCES users(id));                    |
| CHECK       | 自定义条件限制列或多列数据                 | ALTER TABLE users ADD CONSTRAINT check_age CHECK (age >= 18);                                               |
| EXCLUSION   | 复杂约束，保证两行数据在指定操作符下不冲突 | ALTER TABLE bookings ADD CONSTRAINT no_overlap EXCLUDE USING gist(room WITH =, tsrange(start,end) WITH &&); |

### 检查约束
检查约束是最通用的约束类型。它允许您指定某个列中的值必须满足布尔表达式。例如，要要求正的产品价格，您可以使用

```sql
CREATE TABLE products (
    product_no integer,
    name text,
    price numeric CHECK (price > 0)
);

```
如果你使用插入语句，插入一个负的`price`，你会得到报错
```sql
INSERT INTO products (product_no, name, price) VALUES (1, 'apple', -1);
```

报错
```
错误:  关系 "products" 的新列违反了检查约束 "positive_price"
DETAIL:  失败, 行包含(1, apple, -1).
```

如果你想修改这个约束的名字，你可以使用`CONSTRAINT`关键字

```sql
CREATE TABLE products (
    product_no integer,
    name text,
    price numeric CONSTRAINT positive_price CHECK (price > 0)
);
```

### 非空约束

非空约束只是指定列不得采用 null 值。一个语法示例

```sql
CREATE TABLE products (
    product_no integer NOT NULL,
    name text NOT NULL,
    price numeric
);
```

### 唯一约束
唯一约束确保列或一组列中包含的数据在表的所有行中都是唯一的。语法是
```sql
CREATE TABLE products (
    product_no integer UNIQUE,
    name text,
    price numeric
);
```
可以写成列的形式
```sql
CREATE TABLE products (
    product_no integer,
    name text,
    price numeric,
    UNIQUE (product_no)
);
```
要为一组列定义唯一约束，请将其写为表约束，列名称用逗号分隔
```sql
CREATE TABLE example (
    a integer,
    b integer,
    c integer,
    UNIQUE (a, c)
);
```
给约束自定义名称
```sql
CREATE TABLE products (
    product_no integer CONSTRAINT must_be_different UNIQUE,
    name text,
    price numeric
);
```

### 主键
主键约束表示列或一组列可以用作表中行的唯一标识符。这要求值既是唯一的又是非空的
```sql
CREATE TABLE products (
    product_no integer PRIMARY KEY,
    name text,
    price numeric
);
```
添加主键会自动在主键中列出的列或列组上创建一个唯一的 B 树索引，并强制将列标记为 NOT NULL

一个表最多只能有一个主键。（可以有任意数量的唯一和非空约束，它们在功能上几乎是相同的，但只能有一个被标识为主键。）关系数据库理论规定每个表都必须有一个主键。 PostgreSQL 不强制执行此规则，但通常最好遵循它

主键对于文档目的和客户端应用程序都很有用。例如，允许修改行值的 GUI 应用程序可能需要知道表的主键，以便能够唯一地标识行。如果声明了主键，数据库系统也会以各种方式使用它；例如，主键定义了引用其表的外键的默认目标列

### 外键约束

```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);
```

- 级联行为

| 选项          | 父表删除/更新时对子表的影响      |
| ------------- | -------------------------------- |
| `CASCADE`     | 自动删除/更新子表对应行          |
| `RESTRICT`    | 如果被引用，阻止删除/更新        |
| `SET NULL`    | 把子表对应列设为 `NULL`          |
| `SET DEFAULT` | 把子表对应列设为默认值           |
| `NO ACTION`   | 和 `RESTRICT` 类似，只是延迟检查 |

[返回目录](#目录)

## 常用数据函数

**字符串函数**

- 长度、截取、拼接
```sql
SELECT LENGTH('hello');       -- 5  获取字符串长度

SELECT LEFT('postgres', 4); -- 'Post'  获取左侧 4 个字符

SELECT RIGHT('postgres', 4);-- 'SQL'   获取右侧 4 个字符

SELECT CONCAT('Hello', ' ', 'World'); -- 'Hello World'  字符串拼接

SELECT 'Hello' || ' World' as hello;  -- 'Hello World'  另一种拼接方式
```

- 大小写转换
```sql
SELECT UPPER('hello'); -- 'HELLO' 转换为大写

SELECT LOWER('HELLO'); -- 'hello' 转换为小写

SELECT INITCAP('hello world'); -- 'Hello World'  每个单词首字母大写
```

- 去空格
```sql
SELECT TRIM('  hello  ');  -- 'hello'  去掉两端空格

SELECT LTRIM('  hello');   -- 'hello'  去掉左侧空格

SELECT RTRIM('hello  ');   -- 'hello'  去掉右侧空格
```

- 查找与替换
```sql
SELECT POSITION('SQL' IN 'postgres'); -- 9  查找子字符串位置

SELECT REPLACE('hello world', 'world', 'postgres'); -- 'hello postgres' 替换

SELECT SUBSTRING('postgres' FROM 5 FOR 3); -- 'gre'  截取子字符串
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

SELECT VERSION(); -- 获取 postgres 版本

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

[返回目录](#目录)

## 系统信息函数

### 会话基本信息

| 函数 / 变量                              | 说明                                         | 示例                                                                      |
| ---------------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------- |
| `current_database()`                     | 当前会话所在的数据库名                       | `SELECT current_database();`                                              |
| `current_schema()`                       | 当前搜索路径中的第一个 schema                | `SELECT current_schema();`                                                |
| `current_schemas(include_implicit bool)` | 当前搜索路径中的所有 schema 列表             | `SELECT current_schemas(true);`                                           |
| `current_user`                           | 当前会话的执行用户（可能受 `SET ROLE` 影响） | `SELECT current_user;`                                                    |
| `session_user`                           | 会话初始用户（不会随 `SET ROLE` 变化）       | `SELECT session_user;`                                                    |
| `user`                                   | 与 `current_user` 等价                       | `SELECT user;`                                                            |
| `pg_backend_pid()`                       | 当前会话的后端进程 PID                       | `SELECT pg_backend_pid();`                                                |
| `inet_client_addr()`                     | 客户端 IP 地址                               | `SELECT inet_client_addr();`                                              |
| `inet_client_port()`                     | 客户端端口                                   | `SELECT inet_client_port();`                                              |
| `inet_server_addr()`                     | 服务器 IP 地址                               | `SELECT inet_server_addr();`                                              |
| `inet_server_port()`                     | 服务器端口                                   | `SELECT inet_server_port();`                                              |
| `application_name` *(GUC)*               | 当前连接设置的应用名                         | `SHOW application_name;` 或 `SELECT current_setting('application_name');` |
| `session_authorization`                  | 当前会话的授权用户名                         | `SHOW session_authorization;`                                             |

### 会话事务信息

| 函数                             | 说明                       | 示例                                                  |
| -------------------------------- | -------------------------- | ----------------------------------------------------- |
| `txid_current()`                 | 当前事务 ID（数值）        | `SELECT txid_current();`                              |
| `txid_current_snapshot()`        | 当前事务快照（可见性信息） | `SELECT txid_current_snapshot();`                     |
| `txid_snapshot_xmin('snapshot')` | 从快照取最小事务 ID        | `SELECT txid_snapshot_xmin(txid_current_snapshot());` |
| `txid_snapshot_xmax('snapshot')` | 从快照取最大事务 ID        | `SELECT txid_snapshot_xmax(txid_current_snapshot());` |
| `txid_snapshot_xip('snapshot')`  | 从快照取未提交事务列表     | `SELECT txid_snapshot_xip(txid_current_snapshot());`  |

### 会话运行状态

这些通常配合系统视图 `pg_stat_activity` 使用，函数直接获取有限信息：

| 函数                                            | 说明                       | 示例                                                          |
| ----------------------------------------------- | -------------------------- | ------------------------------------------------------------- |
| pg_stat_get_backend_pid(backend_id)             | 获取后台进程 PID           | SELECT pg_stat_get_backend_pid(1);                            |
| pg_stat_get_backend_activity(backend_id)        | 获取后台进程正在执行的 SQL | SELECT pg_stat_get_backend_activity(pg_backend_pid());        |
| pg_stat_get_backend_client_addr(backend_id)     | 获取客户端 IP              | SELECT pg_stat_get_backend_client_addr(pg_backend_pid());     |
| pg_stat_get_backend_client_port(backend_id)     | 获取客户端端口             | SELECT pg_stat_get_backend_client_port(pg_backend_pid());     |
| pg_stat_get_backend_start(backend_id)           | 会话开始时间               | SELECT pg_stat_get_backend_start(pg_backend_pid());           |
| pg_stat_get_backend_xact_start(backend_id)      | 事务开始时间               | SELECT pg_stat_get_backend_xact_start(pg_backend_pid());      |
| pg_stat_get_backend_wait_event(backend_id)      | 当前等待的事件类型         | SELECT pg_stat_get_backend_wait_event(pg_backend_pid());      |
| pg_stat_get_backend_wait_event_type(backend_id) | 等待事件大类               | SELECT pg_stat_get_backend_wait_event_type(pg_backend_pid()); |

> 这些 `pg_stat_get_backend_*` 函数大多是内部统计接口，实际用时更多人直接查

```sql
SELECT * FROM pg_stat_activity WHERE pid = pg_backend_pid();
```

### 会话配置函数

| 函数                                   | 说明                 | 示例                                                        |
| -------------------------------------- | -------------------- | ----------------------------------------------------------- |
| current_setting('param')               | 获取当前会话参数值   | SELECT current_setting('search_path');                      |
| set_config('param', 'value', is_local) | 设置当前会话参数值   | SELECT set_config('search_path', 'myschema,public', false); |
| pg_show_all_settings() *(>=17)*        | 列出所有当前会话设置 | SELECT * FROM pg_show_all_settings();                       |

### 会话时间与生命周期

| 函数                            | 说明                           | 示例                               |
| ------------------------------- | ------------------------------ | ---------------------------------- |
| clock_timestamp()               | 当前实际时间（调用时立即取值） | SELECT clock_timestamp();          |
| statement_timestamp()           | 当前 SQL 开始执行的时间        | SELECT statement_timestamp();      |
| transaction_timestamp() / now() | 当前事务开始的时间             | SELECT transaction_timestamp();    |
| pg_postmaster_start_time()      | 数据库服务启动时间             | SELECT pg_postmaster_start_time(); |

### 访问权限查询函数

这些函数通常返回布尔值，用于判断当前用户或指定用户是否拥有对某个对象的权限

**数据库权限函数**

| 函数                                            | 说明                           | 示例                                                                        |
| ----------------------------------------------- | ------------------------------ | --------------------------------------------------------------------------- |
| has_database_privilege(dbname, privilege)       | 判断当前用户是否拥有数据库权限 | SELECT has_database_privilege(current_user, current_database(), 'CONNECT'); |
| has_database_privilege(user, dbname, privilege) | 判断指定用户是否拥有数据库权限 | SELECT has_database_privilege('alice', 'mydb', 'CREATE');                   |

**可用的 privilege 类型**

- CREATE      -- 创建模式（schema）
- CONNECT     -- 连接数据库
- TEMP        -- 创建临时表
- TEMPORARY   -- TEMP 的别名

**模式权限函数**

| 函数                                              | 说明                         | 示例                                                    |
| ------------------------------------------------- | ---------------------------- | ------------------------------------------------------- |
| has_schema_privilege(schemaname, privilege)       | 判断当前用户是否拥有模式权限 | SELECT has_schema_privilege('public', 'USAGE');         |
| has_schema_privilege(user, schemaname, privilege) | 判断指定用户是否拥有模式权限 | SELECT has_schema_privilege('bob', 'public', 'CREATE'); |

**可用的 privilege 类型**

- CREATE  -- 创建对象
- USAGE   -- 使用 schema 中的对象

**表/视图/序列权限函数**

| 函数                                            | 说明                       | 示例                                                       |
| ----------------------------------------------- | -------------------------- | ---------------------------------------------------------- |
| `has_table_privilege(relname, privilege)`       | 判断当前用户是否拥有表权限 | `SELECT has_table_privilege('mytable', 'SELECT');`         |
| `has_table_privilege(user, relname, privilege)` | 判断指定用户是否拥有表权限 | `SELECT has_table_privilege('alice', 'orders', 'INSERT');` |

**可用的 privilege 类型**

- SELECT
- INSERT
- UPDATE
- DELETE
- TRUNCATE
- REFERENCES
- TRIGGER

> 注意：这里的 `relname` 可以是表、视图、物化视图、序列、外部表等

**列权限函数**

| 函数                                                     | 说明                     | 示例                                                                 |
| -------------------------------------------------------- | ------------------------ | -------------------------------------------------------------------- |
| `has_column_privilege(relname, column, privilege)`       | 判断当前用户是否有列权限 | `SELECT has_column_privilege('mytable', 'price', 'UPDATE');`         |
| `has_column_privilege(user, relname, column, privilege)` | 判断指定用户是否有列权限 | `SELECT has_column_privilege('bob', 'products', 'price', 'SELECT');` |

**可用的 privilege 类型**

- SELECT
- INSERT
- UPDATE
- REFERENCES

**函数权限函数**

| 函数                                                | 说明                       | 示例                                                                          |
| --------------------------------------------------- | -------------------------- | ----------------------------------------------------------------------------- |
| `has_function_privilege(funcname, privilege)`       | 判断当前用户是否有函数权限 | `SELECT has_function_privilege('myfunc(int, text)', 'EXECUTE');`              |
| `has_function_privilege(user, funcname, privilege)` | 判断指定用户是否有函数权限 | `SELECT has_function_privilege('alice', 'add_numbers(int, int)', 'EXECUTE');` |

**可用的 privilege 类型**：

- EXECUTE

**语言权限函数**

| 函数                                                | 说明                       | 示例                                                        |
| --------------------------------------------------- | -------------------------- | ----------------------------------------------------------- |
| `has_language_privilege(langname, privilege)`       | 判断当前用户是否有语言权限 | `SELECT has_language_privilege('plpgsql', 'USAGE');`        |
| `has_language_privilege(user, langname, privilege)` | 判断指定用户是否有语言权限 | `SELECT has_language_privilege('bob', 'plpgsql', 'USAGE');` |

**可用的 privilege 类型**

- USAGE

**大型对象权限函数**

| 函数                                                     | 说明                   | 示例                                                                         |
| -------------------------------------------------------- | ---------------------- | ---------------------------------------------------------------------------- |
| `has_foreign_data_wrapper_privilege(fdwname, privilege)` | 判断 FDW 权限          | `SELECT has_foreign_data_wrapper_privilege('myfdw', 'USAGE');`               |
| `has_foreign_server_privilege(servername, privilege)`    | 判断外部服务器权限     | `SELECT has_foreign_server_privilege('myserver', 'USAGE');`                  |
| `has_foreign_table_privilege(relname, privilege)`        | 判断外部表权限         | `SELECT has_foreign_table_privilege('my_foreign_table', 'SELECT');`          |
| `has_foreign_table_privilege(user, relname, privilege)`  | 判断指定用户外部表权限 | `SELECT has_foreign_table_privilege('alice', 'my_foreign_table', 'INSERT');` |
| `has_largeobject_privilege(loid, privilege)`             | 判断大型对象权限       | `SELECT has_largeobject_privilege(12345, 'READ');`                           |

**大型对象 privilege 类型**：

- SELECT
- UPDATE
- INSERT
- DELETE
- READ
- WRITE

[返回目录](#目录)

## 系统管理函数

这些函数是 DBA 级工具，用于数据库维护、会话管理、锁管理、WAL 控制、统计信息重置等


### 会话与连接管理

| 函数                        | 说明                                         | 示例                                              |
| --------------------------- | -------------------------------------------- | ------------------------------------------------- |
| `pg_cancel_backend(pid)`    | 取消指定 PID 的查询（但不终止会话）          | `SELECT pg_cancel_backend(12345);`                |
| `pg_terminate_backend(pid)` | 终止指定 PID 的会话                          | `SELECT pg_terminate_backend(12345);`             |
| `pg_reload_conf()`          | 重新加载配置文件（等价于 `pg_ctl reload`）   | `SELECT pg_reload_conf();`                        |
| `pg_rotate_logfile()`       | 滚动 PostgreSQL 日志文件                     | `SELECT pg_rotate_logfile();`                     |
| `pg_backend_pid()`          | 返回当前会话的 PID                           | `SELECT pg_backend_pid();`                        |
| `pg_current_logfile()`      | 返回当前日志文件路径（`csvlog`、`stderr`等） | `SELECT pg_current_logfile();`                    |
| `pg_stat_activity` (视图)   | 当前所有会话、状态、SQL                      | `SELECT pid, state, query FROM pg_stat_activity;` |
| `pg_blocking_pids(pid)`     | 查看阻塞指定 PID 的会话                      | `SELECT pg_blocking_pids(12345);`                 |

### 数据库与表维护

| 函数                                               | 说明                          | 示例                                                    |
| -------------------------------------------------- | ----------------------------- | ------------------------------------------------------- |
| `pg_stat_reset()`                                  | 重置所有统计信息              | `SELECT pg_stat_reset();`                               |
| `pg_stat_reset_shared('bgwriter' \| 'wal' ...)`    | 重置共享统计信息              | `SELECT pg_stat_reset_shared('wal');`                   |
| `pg_stat_reset_single_table_counters(rel_oid)`     | 重置指定表的统计信息          | `SELECT pg_stat_reset_single_table_counters(12345);`    |
| `pg_stat_reset_single_function_counters(func_oid)` | 重置指定函数的统计信息        | `SELECT pg_stat_reset_single_function_counters(12345);` |
| `pg_relation_size(relation)`                       | 表或索引的大小（不含 TOAST）  | `SELECT pg_relation_size('mytable');`                   |
| `pg_total_relation_size(relation)`                 | 表的总大小（含 TOAST 和索引） | `SELECT pg_total_relation_size('mytable');`             |
| `pg_table_size(relation)`                          | 表大小（含 TOAST，不含索引）  | `SELECT pg_table_size('mytable');`                      |
| `pg_indexes_size(relation)`                        | 索引总大小                    | `SELECT pg_indexes_size('mytable');`                    |
| `pg_size_pretty(bigint)`                           | 字节数格式化为可读形式        | `SELECT pg_size_pretty(1048576);`                       |
| `pg_database_size(name)`                           | 数据库大小                    | `SELECT pg_database_size('mydb');`                      |
| `pg_tablespace_size(name)`                         | 表空间大小                    | `SELECT pg_tablespace_size('pg_default');`              |

### 锁与事务管理

| 函数                                                            | 说明                           | 示例                                    |
| --------------------------------------------------------------- | ------------------------------ | --------------------------------------- |
| `pg_try_advisory_lock(key)` / `pg_advisory_lock(key)`           | 获取会话级建议锁               | `SELECT pg_advisory_lock(12345);`       |
| `pg_try_advisory_xact_lock(key)` / `pg_advisory_xact_lock(key)` | 获取事务级建议锁               | `SELECT pg_advisory_xact_lock(12345);`  |
| `pg_advisory_unlock(key)` / `pg_advisory_unlock_all()`          | 释放建议锁                     | `SELECT pg_advisory_unlock(12345);`     |
| `pg_blocking_pids(pid)`                                         | 查看阻塞当前 PID 的会话        | `SELECT pg_blocking_pids(12345);`       |
| `pg_is_in_recovery()`                                           | 是否处于恢复模式（备用节点）   | `SELECT pg_is_in_recovery();`           |
| `pg_safe_snapshot_export()` *(PG 17+)*                          | 导出一个可安全使用的快照       | (内部用，调用示例较少)                  |
| `txid_current()`                                                | 当前事务 ID                    | `SELECT txid_current();`                |
| `txid_current_snapshot()`                                       | 当前快照                       | `SELECT txid_current_snapshot();`       |
| `txid_status(xid)`                                              | 事务状态（已提交/中止/进行中） | `SELECT txid_status(100);`              |
| `pg_xact_commit_timestamp(xid)`                                 | 事务提交时间（需启用）         | `SELECT pg_xact_commit_timestamp(100);` |

### WAL 与归档管理

| 函数                            | 说明                             | 示例                                                 |
| ------------------------------- | -------------------------------- | ---------------------------------------------------- |
| `pg_switch_wal()` *(PG 10+)*    | 立即切换 WAL 段                  | `SELECT pg_switch_wal();`                            |
| `pg_create_restore_point(name)` | 创建恢复点（用于 PITR）          | `SELECT pg_create_restore_point('my_point');`        |
| `pg_current_wal_lsn()`          | 当前 WAL LSN                     | `SELECT pg_current_wal_lsn();`                       |
| `pg_last_wal_receive_lsn()`     | 上次接收到的 WAL LSN（备用节点） | `SELECT pg_last_wal_receive_lsn();`                  |
| `pg_last_wal_replay_lsn()`      | 上次回放的 WAL LSN（备用节点）   | `SELECT pg_last_wal_replay_lsn();`                   |
| `pg_current_wal_insert_lsn()`   | 当前 WAL 插入位置                | `SELECT pg_current_wal_insert_lsn();`                |
| `pg_walfile_name(lsn)`          | 根据 LSN 获取 WAL 文件名         | `SELECT pg_walfile_name('0/16B6C50');`               |
| `pg_walfile_name_offset(lsn)`   | 返回 WAL 文件名和文件内偏移量    | `SELECT * FROM pg_walfile_name_offset('0/16B6C50');` |
| `pg_switch_xlog()` *(<=PG 9.6)* | 旧版本 WAL 切换函数              | `SELECT pg_switch_xlog();`                           |


### 统计与性能监控

| 函数 / 视图                                        | 说明                       | 示例                                                              |
| -------------------------------------------------- | -------------------------- | ----------------------------------------------------------------- |
| `pg_stat_reset()`                                  | 重置统计信息               | `SELECT pg_stat_reset();`                                         |
| `pg_stat_file(path, missing_ok)`                   | 获取服务器上文件的状态     | `SELECT * FROM pg_stat_file('postgresql.conf', true);`            |
| `pg_ls_dir(dirname, missing_ok, include_dot_dirs)` | 列出目录内容               | `SELECT * FROM pg_ls_dir('pg_wal');`                              |
| `pg_ls_waldir()`                                   | 列出 WAL 目录的文件        | `SELECT * FROM pg_ls_waldir();`                                   |
| `pg_ls_archive_statusdir()`                        | 列出 WAL 归档状态文件      | `SELECT * FROM pg_ls_archive_statusdir();`                        |
| `pg_read_file(filename, offset, length)`           | 读取服务器文件内容         | `SELECT pg_read_file('postgresql.conf', 0, 1000);`                |
| `pg_read_binary_file(filename, offset, length)`    | 读取二进制文件             | `SELECT pg_read_binary_file('base/16384/12345', 0, 1024);`        |
| `pg_read_file_v2(...)` *(PG 16+)*                  | 加强版文件读取             | (参数较多，示例较复杂，官方文档详见)                              |
| `pg_stat_statements` *(扩展)*                      | SQL 执行统计（需启用扩展） | `SELECT * FROM pg_stat_statements ORDER BY total_exec_time DESC;` |
| `pg_stat_io` *(PG 15+)*                            | I/O 统计                   | `SELECT * FROM pg_stat_io;`                                       |
| `pg_stat_all_tables` / `pg_stat_all_indexes`       | 表 & 索引访问统计          | `SELECT * FROM pg_stat_all_tables;`                               |
| `pg_statio_all_tables`                             | 表 I/O 命中率等            | `SELECT * FROM pg_statio_all_tables;`                             |


### 复制与备份

| 函数 / 视图                                              | 说明                       | 示例                                                                     |
| -------------------------------------------------------- | -------------------------- | ------------------------------------------------------------------------ |
| `pg_create_physical_replication_slot(name)`              | 创建物理复制槽             | `SELECT pg_create_physical_replication_slot('slot1');`                   |
| `pg_create_logical_replication_slot(name, plugin)`       | 创建逻辑复制槽             | `SELECT pg_create_logical_replication_slot('slot1', 'test_decoding');`   |
| `pg_drop_replication_slot(name)`                         | 删除复制槽                 | `SELECT pg_drop_replication_slot('slot1');`                              |
| `pg_replication_slot_advance(name, lsn)`                 | 推进复制槽位置             | `SELECT pg_replication_slot_advance('slot1', '0/16B6C50');`              |
| `pg_replication_origin_create(name)`                     | 创建复制源                 | `SELECT pg_replication_origin_create('origin1');`                        |
| `pg_replication_origin_drop(name)`                       | 删除复制源                 | `SELECT pg_replication_origin_drop('origin1');`                          |
| `pg_replication_origin_advance(name, lsn)`               | 推进复制源位置             | `SELECT pg_replication_origin_advance('origin1', '0/16B6C50');`          |
| `pg_start_backup(label, fast)` / `pg_stop_backup()`      | 执行基于文件系统的备份     | `SELECT pg_start_backup('label', true);` / `SELECT pg_stop_backup();`    |
| `pg_backup_start_time()`                                 | 获取最后一次备份开始时间   | `SELECT pg_backup_start_time();`                                         |
| `pg_replication_slots` (视图)                            | 当前复制槽信息             | `SELECT * FROM pg_replication_slots;`                                    |
| `pg_stat_replication` (视图)                             | 主节点查看从节点状态       | `SELECT * FROM pg_stat_replication;`                                     |
| `pg_last_wal_receive_lsn()` / `pg_last_wal_replay_lsn()` | 备用节点 WAL 接收/回放位置 | `SELECT pg_last_wal_receive_lsn();` / `SELECT pg_last_wal_replay_lsn();` |


### 角色与权限管理

| 函数                                             | 说明                             | 示例                                                                       |
| ------------------------------------------------ | -------------------------------- | -------------------------------------------------------------------------- |
| `pg_has_role(role, privilege)`                   | 检查当前用户是否具有指定角色权限 | `SELECT pg_has_role('myrole', 'USAGE');`                                   |
| `pg_has_any_role(role)`                          | 检查当前用户是否属于某个角色     | `SELECT pg_has_any_role('myrole');`                                        |
| `pg_has_table_privilege(user, table, privilege)` | 检查表权限                       | `SELECT pg_has_table_privilege('user1', 'mytable', 'SELECT');`             |
| `pg_has_sequence_privilege(...)`                 | 检查序列权限                     | `SELECT pg_has_sequence_privilege('user1', 'mysequence', 'USAGE');`        |
| `pg_has_function_privilege(...)`                 | 检查函数权限                     | `SELECT pg_has_function_privilege('user1', 'myfunc(integer)', 'EXECUTE');` |
| `pg_has_column_privilege(...)`                   |                                  |                                                                            |


\| 检查列权限                      | `SELECT pg_has_column_privilege('user1', 'mytable', 'mycolumn', 'SELECT');` |

### 其他管理类函数

| 函数                                      | 说明                             | 示例                                                       |
| ----------------------------------------- | -------------------------------- | ---------------------------------------------------------- |
| `pg_sleep(seconds)`                       | 让当前会话暂停指定秒数           | `SELECT pg_sleep(5);`                                      |
| `pg_sleep_for(interval)`                  | 按时间间隔暂停                   | `SELECT pg_sleep_for('00:00:05');`                         |
| `pg_sleep_until(timestamp)`               | 暂停到某个时间点                 | `SELECT pg_sleep_until('2025-01-01 00:00:00'::timestamp);` |
| `pg_promote(wait_seconds, check_seconds)` | 提升 standby 节点为主节点        | `SELECT pg_promote();`                                     |
| `pg_is_in_backup()`                       | 是否正在执行 `pg_start_backup()` | `SELECT pg_is_in_backup();`                                |
| `pg_is_in_recovery()`                     | 是否处于恢复模式                 | `SELECT pg_is_in_recovery();`                              |
| `pg_backup_start_time()`                  | 最后一次备份开始时间             | `SELECT pg_backup_start_time();`                           |

[返回目录](#目录)

## 常用表达式

**条件表达式**

常用条件表达式一览

| 表达式     | 描述                                        |
| ---------- | ------------------------------------------- |
| `CASE`     | 通用的条件判断表达式                        |
| `COALESCE` | 返回第一个非空值                            |
| `NULLIF`   | 如果两个值相等则返回 NULL，否则返回第一个值 |
| `GREATEST` | 返回多个表达式中最大的一个                  |
| `LEAST`    | 返回多个表达式中最小的一个                  |

`CASE` 表达式

```sql
SELECT
  name,
  age,
  CASE
    WHEN age < 18 THEN '未成年'
    WHEN age BETWEEN 18 AND 60 THEN '成年人'
    ELSE '老年人'
  END AS age_group
FROM users;
```

`COALESCE(expr1, expr2, ..., exprN)`

返回第一个非空的值：

```sql
SELECT COALESCE(nickname, username, '匿名') AS display_name FROM users;
```

`NULLIF(expr1, expr2)`

若两个值相等，则返回 `NULL`，否则返回 `expr1`：

```sql
SELECT NULLIF(score, 0) FROM exam_scores;
```

可用于避免除零错误

```sql
SELECT score / NULLIF(total, 0) FROM results;
```

`GREATEST(expr1, expr2, ..., exprN)`

```sql
SELECT GREATEST(price_1, price_2, price_3) AS max_price FROM products;
```

`LEAST(expr1, expr2, ..., exprN)`

```sql
SELECT LEAST(price_1, price_2, price_3) AS min_price FROM products;
```

**子查询表达式**

`WHERE` 子句中的子查询

示例：找出工资高于平均工资的员工

```sql
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

`EXISTS` 子查询

判断子查询是否有结果，返回布尔值

```sql
SELECT name
FROM users
WHERE EXISTS (
    SELECT 1 FROM orders WHERE orders.user_id = users.id
);
```

这条 SQL 语句的含义是：查出所有在 orders 表中至少有一条订单记录的用户的 name

`IN` 子查询

```sql
SELECT name
FROM users
WHERE id IN (
    SELECT user_id FROM orders WHERE amount > 100
);
```

`ANY` / `SOME`：至少一个成立

```sql
SELECT * FROM products
WHERE price > ANY (
    SELECT price FROM products WHERE category = 'books'
);
```

`ALL`：全部都成立

```sql
SELECT * FROM products
WHERE price > ALL (
    SELECT price FROM products WHERE category = 'books'
);
```

标量子查询

如果子查询只返回一行一列，它可以用在任何接受值的地方。

```sql
SELECT name,
       (SELECT MAX(score) FROM exams WHERE exams.user_id = users.id) AS max_score
FROM users;
```

相关子查询

子查询引用了外层查询的字段：

```sql
SELECT name
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.id AND o.amount > 100
);
```

[返回目录](#目录)


## 窗口函数

postgres 的窗口函数在实际开发中应用非常广泛，常用于统计分析、排名、累计计算、数据对比等。

我们可以通过一个简单的例子来展示 postgres窗口函数的各种典型实际应用场景。下面先创建一张示例表，并插入一些示例数据。


示例表结构：`sales`

```sql
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    employee TEXT,
    region TEXT,
    sales_amount INT,
    sale_date DATE
);
```

示例数据：

```sql
INSERT INTO sales (employee, region, sales_amount, sale_date) VALUES
('Alice', 'East', 100, '2024-01-01'),
('Alice', 'East', 150, '2024-01-02'),
('Bob', 'East', 200, '2024-01-01'),
('Bob', 'East', 300, '2024-01-02'),
('Charlie', 'West', 400, '2024-01-01'),
('Charlie', 'West', 350, '2024-01-02'),
('Alice', 'East', 120, '2024-01-03'),
('Bob', 'East', 250, '2024-01-03'),
('Charlie', 'West', 500, '2024-01-03');
```

`ROW_NUMBER()`：为每个员工按时间排序编号

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  ROW_NUMBER() OVER (PARTITION BY employee ORDER BY sale_date) AS row_num
FROM sales;
```

**实际用途**：查找每个员工的第一笔销售记录（可配合子查询使用）


`RANK()` 和 `DENSE_RANK()`：排名（有并列）

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  RANK() OVER (PARTITION BY sale_date ORDER BY sales_amount DESC) AS rank
FROM sales;
```

**实际用途**：查每天销售额排名。


`SUM()` over window：计算每人累计销售额

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  SUM(sales_amount) OVER (PARTITION BY employee ORDER BY sale_date) AS running_total
FROM sales;
```

**实际用途**：生成报表，展示每个员工的逐日累计销售额。

`LAG()` / `LEAD()`：取前一行或后一行的值

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  LAG(sales_amount) OVER (PARTITION BY employee ORDER BY sale_date) AS prev_day_sales,
  LEAD(sales_amount) OVER (PARTITION BY employee ORDER BY sale_date) AS next_day_sales
FROM sales;
```

**实际用途**：对比员工每日销售额的变化情况。

`NTILE(n)`：分桶，比如将销售记录分为 3 组

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  NTILE(3) OVER (ORDER BY sales_amount DESC) AS bucket
FROM sales;
```

**实际用途**：将数据划分为 n 等分，比如根据销售额划分高、中、低档销售记录。


`FIRST_VALUE()` / `LAST_VALUE()`：每人第一次/最后一次销售额

```sql
SELECT
  employee,
  sale_date,
  sales_amount,
  FIRST_VALUE(sales_amount) OVER (PARTITION BY employee ORDER BY sale_date) AS first_sale,
  LAST_VALUE(sales_amount) OVER (PARTITION BY employee ORDER BY sale_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_sale
FROM sales;
```

**实际用途**：了解某人一段时间内的首笔或末笔销售情况


[返回目录](#目录)


## 视图

**什么是视图**

视图是一个虚拟表，其内容由一个 SELECT 查询定义，并在每次访问视图时执行查询

```sql
CREATE VIEW view_name AS
SELECT column1, column2
FROM table_name
WHERE condition;
```

本质上是什么？

* 就是一条保存下来的 SQL 查询语句
* 并不存储数据，除非是物化视图
* 在使用视图时，postgres 会将视图替换成对应的 SELECT 语句


**视图的分类**

| 类型       | 描述                                            | 是否持久化数据     |
| ---------- | ----------------------------------------------- | ------------------ |
| 普通视图   | 查询时实时执行 SQL                              | 不持久化           |
| 可更新视图 | 特殊类型的普通视图，可以 `INSERT/UPDATE/DELETE` |                    |
| 物化视图   | 将查询结果缓存                                  | 持久化，可定期刷新 |
| 递归视图   | 使用 WITH RECURSIVE 创建递归层次结构            |                    |

**创建视图**

基本语法

```sql
CREATE VIEW employee_view AS
SELECT id, name, salary FROM employees
WHERE department = 'Sales';
```

带列名别名

```sql
CREATE VIEW employee_summary (emp_id, emp_name) AS
SELECT id, name FROM employees;
```

替代 OR REPLACE

```sql
CREATE OR REPLACE VIEW employee_view AS
SELECT id, name FROM employees WHERE active = true;
```

递归视图

```sql
WITH RECURSIVE subordinates AS (
  SELECT id, manager_id FROM employees WHERE id = 1
  UNION
  SELECT e.id, e.manager_id
  FROM employees e
  JOIN subordinates s ON e.manager_id = s.id
)
SELECT * FROM subordinates;
```


**物化视图**

定义

* 是一种持久化的视图，会保存查询结果；
* 适合用于性能优化；
* 需要手动 `REFRESH` 来更新内容。

语法

```sql
CREATE MATERIALIZED VIEW mv_sales_summary AS
SELECT department, SUM(amount) FROM sales
GROUP BY department;
```

刷新数据

```sql
REFRESH MATERIALIZED VIEW mv_sales_summary;
```

带索引

* 物化视图可以建立索引，提升性能


**更新视图**

默认规则

postgres 会尝试将对视图的 `INSERT/UPDATE/DELETE` 映射到底层表：

* 必须是单表视图
* 没有聚合、DISTINCT、LIMIT、GROUP BY、JOIN、窗口函数、子查询

明确创建规则

```sql
CREATE VIEW updatable_view AS
SELECT id, name FROM employees;

CREATE FUNCTION insert_into_view() RETURNS trigger AS $$
BEGIN
  INSERT INTO employees (id, name) VALUES (NEW.id, NEW.name);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER instead_insert
INSTEAD OF INSERT ON updatable_view
FOR EACH ROW EXECUTE FUNCTION insert_into_view();
```


**查询视图**

```sql
SELECT * FROM employee_view;
```

你可以对视图使用 `WHERE`、`JOIN`、`ORDER BY` 等操作，就像普通表一样


**删除视图**

```sql
DROP VIEW employee_view;
DROP MATERIALIZED VIEW mv_sales_summary;
```

加上 `IF EXISTS` 更安全：

```sql
DROP VIEW IF EXISTS employee_view;
```

**查看视图定义**

查看视图 SQL

```sql
SELECT definition FROM pg_views WHERE viewname = 'employee_view';
```

或者使用 `psql` 工具：

```bash
\d+ employee_view
```

**视图的高级用法**

嵌套视图（视图中调用视图）

```sql
CREATE VIEW sales_summary AS
SELECT department, SUM(amount) AS total FROM sales GROUP BY department;

CREATE VIEW top_departments AS
SELECT * FROM sales_summary WHERE total > 100000;
```

与权限系统配合

* 可以将视图作为权限隔离的手段：

```sql
CREATE VIEW public_employee_view AS
SELECT name, position FROM employees;

REVOKE SELECT ON employees FROM PUBLIC;
GRANT SELECT ON public_employee_view TO readonly_user;
```

性能注意事项

| 问题               | 解决方案                                  |
| ------------------ | ----------------------------------------- |
| 视图嵌套过深       | 查询优化困难，建议使用物化视图            |
| 频繁查询但内容不变 | 使用 `Materialized View` 并定期 `REFRESH` |
| 不能加索引         | 视图本身不能加索引，但物化视图可以        |


系统表中视图的存储

* `pg_views`: 所有普通视图
* `pg_matviews`: 所有物化视图
* `pg_class`: 存储所有表和视图的元数据
* `pg_depend`: 视图与依赖对象的关联


[返回目录](#目录)


## 连接语句 

**内连接**

在 postgres 中，INNER JOIN 的行为如下：

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

**外连接**

postgres 中有多种不同的外连接语句，左连接、右连接、全外连接、交叉连接

| 类型                         | 描述                                                      |
| ---------------------------- | --------------------------------------------------------- |
| LEFT OUTER JOIN（左外连接）  | 保留左表全部记录，即使右表中没有匹配的也保留，右表补 NULL |
| RIGHT OUTER JOIN（右外连接） | 保留右表全部记录，左表没有匹配的补 NULL                   |
| FULL OUTER JOIN（全外连接）  | 左右两边都保留，没有匹配的那一边用 NULL 补上              |


student 表

| id  | name    |
| --- | ------- |
| 1   | Alice   |
| 2   | Bob     |
| 3   | Charlie |

score 表

| student_id | score |
| ---------- | ----- |
| 1          | 95    |
| 2          | 88    |
| 4          | 70    |

左外连接
```sql
SELECT s.id, s.name, sc.score
FROM students s
LEFT OUTER JOIN scores sc
ON s.id = sc.student_id;
```

查询结果
| id  | name    | score |
| --- | ------- | ----- |
| 1   | Alice   | 95    |
| 2   | Bob     | 88    |
| 3   | Charlie | NULL  |

右外连接
```sql
SELECT s.id, s.name, sc.score
FROM students s
RIGHT OUTER JOIN scores sc
ON s.id = sc.student_id;
```

结果
| id   | name  | score |
| ---- | ----- | ----- |
| 1    | Alice | 95    |
| 2    | Bob   | 88    |
| NULL | NULL  | 70    |

全外连接
```sql
SELECT s.id, s.name, sc.score
FROM students s
FULL OUTER JOIN scores sc
ON s.id = sc.student_id;
```

结果

| id   | name    | score |
| ---- | ------- | ----- |
| 1    | Alice   | 95    |
| 2    | Bob     | 88    |
| 3    | Charlie | NULL  |
| NULL | NULL    | 70    |

交叉连接
```sql
SELECT s.id, s.name, sc.student_id, sc.score
FROM students s
CROSS JOIN scores sc;
```

结果

| id  | name    | student_id | score |
| --- | ------- | ---------- | ----- |
| 1   | Alice   | 1          | 95    |
| 1   | Alice   | 2          | 88    |
| 1   | Alice   | 4          | 70    |
| 2   | Bob     | 1          | 95    |
| 2   | Bob     | 2          | 88    |
| 2   | Bob     | 4          | 70    |
| 3   | Charlie | 1          | 95    |
| 3   | Charlie | 2          | 88    |
| 3   | Charlie | 4          | 70    |

[返回目录](#目录)

## 权限管理

当创建一个对象时，它会被分配一个所有者。所有者通常是执行创建语句的角色。对于大多数类型的对象，初始状态是只有所有者（或超级用户）可以对该对象执行任何操作。要允许其他角色使用它，必须授予权限。

有不同类型的权限：SELECT、INSERT、UPDATE、DELETE、TRUNCATE、REFERENCES、TRIGGER、CREATE、CONNECT、TEMPORARY、EXECUTE、USAGE、SET、ALTER SYSTEM 和 MAINTAIN。适用于特定对象的权限取决于对象的类型（表、函数等）。有关这些权限含义的更多详细信息将在下面出现。以下章节和章节还将向您展示如何使用这些权限。

修改或销毁对象的权利是对象所有者固有的，并且本身不能被授予或撤销

可以使用适合该对象的 ALTER 命令将对象分配给新的所有者，例如
```sql
ALTER TABLE table_name OWNER TO new_owner;
```
超级用户始终可以这样做；普通角色只有在它们既是对象的当前所有者（或继承了拥有角色的权限）并且能够 SET ROLE 到新的拥有角色时才能这样做。

要分配权限，请使用 GRANT 命令。例如，如果 joe 是一个现有角色，而 accounts 是一个现有表，则可以使用以下命令授予更新表的权限
```sql
GRANT UPDATE ON accounts TO joe;
```
在特定权限的位置写入 ALL 将授予与对象类型相关的所有权限。

特殊的 “角色” 名称 PUBLIC 可用于向系统上的每个角色授予权限。此外，可以设置 “组” 角色来帮助管理数据库中有许多用户时的权限 - 有关详细信息，请参阅第 21 章。

要撤销先前授予的权限，请使用名称恰当的 REVOKE 命令
```sql
REVOKE ALL ON accounts FROM PUBLIC;
```

通常，只有对象的所有者（或超级用户）才能授予或撤销对象的权限。但是，可以授予权限 “带有授予选项”，这使接收者有权将其依次授予其他人。如果随后撤销授予选项，则所有从该接收者那里获得权限的人（直接或通过一系列授予）都将失去该权限。有关详细信息，请参阅 GRANT 和 REVOKE 参考页。

对象的所有者可以选择撤销他们自己的普通权限，例如使表对自己和其他人也变为只读。但是，所有者始终被视为拥有所有授予选项，因此他们始终可以重新授予自己的权限。

可用的权限是

- SELECT 
 
允许从表、视图、物化视图或其他类似表的对象的任何列或特定列执行 SELECT。还允许使用 COPY TO。此权限还需要在 UPDATE、DELETE 或 MERGE 中引用现有列值。对于序列，此权限还允许使用 currval 函数。对于大对象，此权限允许读取对象。

- INSERT 

允许将新行 INSERT 到表、视图等中。可以在特定列上授予，在这种情况下，只能在 INSERT 命令中分配这些列（因此其他列将接收默认值）。还允许使用 COPY FROM。

- UPDATE 

允许 UPDATE 表、视图等的任何列或特定列。（实际上，任何重要的 UPDATE 命令都需要 SELECT 权限，因为它必须引用表列来确定要更新的行，和/或计算列的新值。） SELECT ... FOR UPDATE 和 SELECT ... FOR SHARE 还要求至少在一个列上具有此权限，此外还需要 SELECT 权限。对于序列，此权限允许使用 nextval 和 setval 函数。对于大对象，此权限允许写入或截断对象。

- DELETE 

允许从表、视图等中 DELETE 行。（实际上，任何重要的 DELETE 命令都需要 SELECT 权限，因为它必须引用表列来确定要删除的行。）

- TRUNCATE 

允许在表上执行 TRUNCATE。

- REFERENCES 

允许创建引用表或表的特定列的外键约束。

- TRIGGER 

允许在表、视图等上创建触发器。

- CREATE 

对于数据库，允许在数据库中创建新的模式和发布，并允许在数据库中安装受信任的扩展。

对于模式，允许在模式中创建新对象。要重命名现有对象，您必须拥有该对象并且具有包含模式的此权限。

对于表空间，允许在表空间中创建表、索引和临时文件，并允许创建将表空间作为其默认表空间的数据库。

请注意，撤销此权限不会更改现有对象的存在或位置。

- CONNECT 

允许被授权者连接到数据库。此权限在连接启动时进行检查（除了检查 pg_hba.conf 施加的任何限制）。

- TEMPORARY 

允许在使用数据库时创建临时表。

- EXECUTE 

允许调用函数或过程，包括使用在函数之上实现的任何运算符。这是唯一适用于函数和过程的权限类型。

- USAGE 

对于过程语言，允许使用该语言创建该语言的函数。这是唯一适用于过程语言的权限类型。

对于模式，允许访问模式中包含的对象（假设也满足对象自身的权限要求）。本质上，这允许被授权者 “查找” 模式中的对象。如果没有此权限，仍然可以通过查询系统目录来查看对象名称。此外，在撤销此权限后，现有会话可能具有先前执行此查找的语句，因此这不是防止对象访问的完全安全的方法。

对于序列，允许使用 currval 和 nextval 函数。

对于类型和域，允许在创建表、函数和其他模式对象时使用类型或域。（请注意，此权限不控制类型的所有 “使用”，例如查询中出现的类型值。它仅阻止创建依赖于该类型的对象。此权限的主要目的是控制哪些用户可以在类型上创建依赖项，这可能会阻止所有者以后更改类型。）

对于外部数据包装器，允许使用外部数据包装器创建新服务器。

对于外部服务器，允许使用服务器创建外部表。被授权者还可以创建、更改或删除与该服务器关联的自己的用户映射。

- SET 

允许在当前会话中将服务器配置参数设置为新值。（虽然可以在任何参数上授予此权限，但除了通常需要超级用户权限才能设置的参数外，它没有任何意义。）

- ALTER SYSTEM 

允许使用 ALTER SYSTEM 命令将服务器配置参数配置为新值。

- MAINTAIN 

允许对关系执行 VACUUM、ANALYZE、CLUSTER、REFRESH MATERIALIZED VIEW、REINDEX 和 LOCK TABLE 命令。

其他命令所需的权限在相应命令的参考页面中列出。

当创建对象时，PostgreSQL 默认会授予某些类型的对象权限给 PUBLIC。默认情况下，不会向 PUBLIC 授予表、表列、序列、外部数据包装器、外部服务器、大型对象、模式、表空间或配置参数的任何权限。对于其他类型的对象，默认授予 PUBLIC 的权限如下：数据库的 CONNECT 和 TEMPORARY（创建临时表）权限；函数和过程的 EXECUTE 权限；以及语言和数据类型（包括域）的 USAGE 权限。对象所有者当然可以 REVOKE 默认和明确授予的权限。（为了最大程度的安全性，请在创建对象的同一事务中发出 REVOKE；这样就不会有其他用户可以使用该对象的时间窗口。）此外，可以使用 ALTER DEFAULT PRIVILEGES 命令覆盖这些默认权限设置。

[返回目录](#目录)

## 事务处理

`postgres`事务处理是指在数据库中执行一系列 SQL 语句，使其成为一个不可分割的操作单元，即 要么全部执行成功，要么全部回滚，以确保数据的一致性和完整性

**准备工作**

+ 创建演示表

```sql
CREATE TABLE "public"."users" (
  "user_account" varchar(32) COLLATE "pg_catalog"."default" NOT NULL,
  "username" varchar(32) COLLATE "pg_catalog"."default",
  "user_avatar" varchar(64) COLLATE "pg_catalog"."default",
  "user_profile" varchar(512) COLLATE "pg_catalog"."default",
  "hashed_password" varchar COLLATE "pg_catalog"."default" NOT NULL
);
```

**基本操作**

+ 提交事务

```sql
BEGIN; -- 开启事务

-- SQL 语句
INSERT INTO users (user_account, hashed_password) VALUES ('Alice', 'xxxx');

COMMIT; -- 提交事务
```

+ 回滚事务

```sql
BEGIN

DELETE FROM users;

ROLLBACK;
```

+ 设置回滚点

`SAVEPOINT` 允许在事务内部创建回滚点，部分 SQL 语句可以回滚，而不影响其他 SQL

```sql
BEGIN;

INSERT INTO users (user_account, hashed_password) VALUES ('Alice', 'xxxx');
SAVEPOINT sp1; -- 创建回滚点

INSERT INTO users (user_account, hashed_password) VALUES ('Alice2', 'xxxx');
SAVEPOINT sp2;

INSERT INTO users (user_account, hashed_password) VALUES ('Alice3', 'xxxx');
ROLLBACK TO sp2;

COMMIT; -- 提交事务
```

**事务隔离级别**

在数据库中，事务隔离级别用于控制多个事务并发执行时的可见性，避免数据不一致的问题。postgres 遵循 ACID（原子性、一致性、隔离性、持久性） 原则，并提供四种事务隔离级别

| 隔离级别         | 脏读     | 不可重复读 | 幻读     |
| ---------------- | -------- | ---------- | -------- |
| 读未提交         | 可能发生 | 可能发生   | 可能发生 |
| 读已提交（默认） | 不会发生 | 可能发生   | 可能发生 |
| 可重复读         | 不会发生 | 不会发生   | 可能发生 |
| 可串行化         | 不会发生 | 不会发生   | 不会发生 |


下面我们来逐一介绍

**读未提交/读已提交**

`postgres` 不真正支持读未提交 这个级别，而是当作读已提交处理

即，就算你设置了这个级别，PG 数据库还是会使用读已提交级别事务隔离

**脏读示例（PG 不支持）**

```sql
BEGIN; -- 事务1
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE users SET hashed_password = 'new_hash' WHERE user_account = 'Alice';
SELECT txid_current(); -- 查看当前事务id
-- 保持事务未提交

BEGIN; -- 事务2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM users WHERE user_account = 'Alice';
SELECT txid_current();


ROLLBACK; -- 释放锁，事务 2 的查询继续执行
```

**不可重复读**

+ 事务 1

```sql
BEGIN;
SELECT hashed_password FROM users;
```

+ 事务 2

```sql
BEGIN;
UPDATE users SET hashed_password = 'xxxx';
COMMIT;
```

+ 事务 1

```sql
SELECT hashed_password FROM users;
```

问题：事务 1 在第一次 `SELECT` 时看到的是 hashed_password 与 第二次查询时hashed_password 不一致，这就是不可重复读

**幻读**

+ 事务 1

```sql
BEGIN;
SELECT COUNT(*) FROM users; -- 假设是3
```

+ 事务 2

```sql
BEGIN;
INSERT INTO users (user_account, hashed_password) VALUES ('Alice4', 'xxxx');
COMMIT; -- 增加到4
```

+ 事务 1

```sql
SELECT COUNT(*) FROM users; -- 增加到4
```

**问题**：事务 1 在开始时认为 `users` 里数据为 3，但在事务进行中，别的事务插入了一条数据，事务 1 重新查询时，发现数据数量变了，这就是幻读！

**可串行化**

这个级别会防止所有并发事务间的异常现象（脏读、不可重复读、幻读），并模拟出串行执行的效果

示例：两个事务试图判断总工资是否超过上限，如果没超过就插入新员工

表结构

```sql
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    salary INT
);
```

假设你希望：总工资不能超过 10000

会话 A：

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 查询总工资
SELECT SUM(salary) FROM employees;

-- 如果小于 10000，就插入新员工
INSERT INTO employees (name, salary) VALUES ('alice', 6000);
-- COMMIT;
```
会话 B（并发执行）：

```sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 查询总工资
SELECT SUM(salary) FROM employees;

-- 也判断为小于 10000，于是插入
INSERT INTO employees (name, salary) VALUES ('bob', 6000);

COMMIT;
```

会话 A 提交

```sql
COMMIT;
```

会报错

```
ERROR: could not serialize access due to read/write dependencies among transactions
```

postgres 发现两个事务虽然在一开始都看到工资小于 10000，但同时插入后将违反业务逻辑（工资总额实际超过了），所以强制中止一个事务来防止幻读

> 这就是事务隔离级别 `SERIALIZABLE` 的意义：在并发读写逻辑上模拟串行操作，保护业务语义的一致性。

建议
-  `SERIALIZABLE` 用于重要并发控制，如资金扣除、库存操作    
- 遇到 `could not serialize` 错误，建议应用层重试事务 
- 不要滥用 `SERIALIZABLE`，性能开销大，优先考虑 `REPEATABLE READ` 


**设置事务隔离级别**

在事务中设置

```sql
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SQL 语句
COMMIT;
```

在会话级别设置

```sql
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

+ 这会影响当前会话中的所有事务

在 postgres 配置文件 `postgres.conf` 设置（全局）

```sql
default_transaction_isolation = 'read committed'
```

+ 影响所有数据库的默认隔离级别

**自动提交**

postgres 默认开启自动提交模式，即每条 SQL 语句都会被自动提交。如果要手动管理事务，需要显式使用 `BEGIN`

```sql
SET AUTOCOMMIT TO OFF;
```

[返回目录](#目录)

## 触发器

`postgres`的触发器`Trigger`是一类特殊的数据库对象，在表的 INSERT、UPDATE 或 DELETE 事件发生时，自动执行预定义的函数（触发器函数）。它常用于 数据完整性约束、审计日志、自动计算、复杂的业务逻辑处理等场景

**触发器的构成**

一个完整的触发器由两个部分组成：

- 触发器函数：触发器执行的具体逻辑，必须返回 `TRIGGER` 类型
- 触发器：绑定到表的某个事件上，调用触发器函数

**触发器的类型**

按照触发时间分类

+ BEFORE 触发器（在事件发生前执行）
+ AFTER 触发器（在事件发生后执行）
+ INSTEAD OF 触发器（替代事件执行，仅适用于视图）

按照触发事件分类

+ INSERT 触发器（在插入新数据时触发）
+ UPDATE 触发器（在数据更新时触发）
+ DELETE 触发器（在数据删除时触发）
+ TRUNCATE 触发器（在 `TRUNCATE` 操作时触发）

按照触发级别分类

+ 行级触发器：对受影响的每一行数据触发一次
+ 语句级触发器：对整个 SQL 语句仅触发一次

**创建触发器**

postgres 触发器的创建需要两步：

- 编写触发器函数（必须返回 `TRIGGER` 类型）
- 创建触发器并绑定到表

假设我们有一个 `users` 表，我们希望在有新用户插入时，自动记录日志到 `user_logs` 表中

**示例 1：审计日志**

Step 1: 创建审计日志表

```sql
CREATE TABLE user_logs (
    log_id SERIAL PRIMARY KEY,
    user_id UUID,
    action TEXT,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Step 2: 编写触发器函数

```sql
CREATE OR REPLACE FUNCTION log_user_insert() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_logs (user_id, action)
    VALUES (NEW.id, 'User created');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Step 3: 创建触发器

```sql
CREATE TRIGGER user_insert_trigger
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_insert();
```

**示例 2：自动更新修改时间**

假设 `users` 表中有一个 `updated_at` 字段，我们希望在用户数据更新时，自动更新 `updated_at` 时间戳

Step 1: 在 `users` 表添加 `updated_at` 字段

```sql
ALTER TABLE users ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

Step 2: 创建触发器函数

```sql
CREATE OR REPLACE FUNCTION update_timestamp() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Step 3: 创建触发器

```sql
CREATE TRIGGER update_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();
```

**示例 3：防止误删除**

有时我们不希望某些重要数据被删除，可以通过`BEFORE DELETE`触发器阻止删除

Step 1: 创建触发器函数

```sql
CREATE OR REPLACE FUNCTION prevent_delete() RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION '不允许删除数据!';
END;
$$ LANGUAGE plpgsql;
```

Step 2: 绑定到 **users** 表

```sql
CREATE TRIGGER prevent_users_deletion
BEFORE DELETE ON users
FOR EACH ROW
EXECUTE FUNCTION prevent_delete();
```

**触发器的管理**

查看已有触发器
```sql
SELECT tgname, relname, tgtype, proname 
FROM pg_trigger 
JOIN pg_class ON pg_trigger.tgrelid = pg_class.oid
JOIN pg_proc ON pg_trigger.tgfoid = pg_proc.oid
WHERE NOT tgisinternal;
```

删除触发器
```sql
DROP TRIGGER IF EXISTS user_insert_trigger ON users;
```

删除触发器函数
```sql
DROP FUNCTION IF EXISTS log_user_insert();
```

[返回目录](#目录)


## 存储过程

postgres 中的存储过程，是一种在数据库中定义的可重复使用的程序单元，用于封装复杂的业务逻辑和数据处理操作，类似编程语言的函数

**示例**

+ 创建存储过程

```sql
CREATE PROCEDURE insert_users (user_account TEXT, hashed_password TEXT) LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO users (user_account, hashed_password)
  VALUES
  (user_account, hashed_password);
END $$;
```

+ 调用

```sql
CALL insert_users(value1, value2);
```

**事务控制**

```sql
CREATE PROCEDURE update_salary(emp_id INT, new_salary NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees SET salary = new_salary WHERE id = emp_id;
    
    -- 如果工资小于 0，则回滚事务
    IF new_salary < 0 THEN
        ROLLBACK;
    ELSE
        COMMIT;
    END IF;
END;
$$;
```

**循环**

```sql
CREATE PROCEDURE insert_multiple_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 5 LOOP
        INSERT INTO employees (name, salary) VALUES ('Employee_' || i, i * 1000);
        i := i + 1;
    END LOOP;
END;
$$;
```

**带输入和输出参数**

```sql
CREATE PROCEDURE get_employee_salary(IN emp_id INT, OUT emp_salary NUMERIC)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT salary INTO emp_salary FROM employees WHERE id = emp_id;
END;
$$;
```

**删除存储过程**

```sql
DROP PROCEDURE xxxxx(TEXT, NUMERIC);
```

[返回目录](#目录)


## 模式管理

在 postgres 中，模式（schema）是一个逻辑命名空间，用来组织数据库中的对象，比如表、视图、函数、类型等

> schema 就像数据库里的“文件夹”或“命名空间”，用来隔离和管理不同的数据库对象，防止命名冲突
>

### 简介

假设你有两个团队在开发两个系统，他们都需要一个叫 `users` 的表：

```sql
CREATE SCHEMA hr;
CREATE SCHEMA sales;

CREATE TABLE hr.users (...);     -- 人力资源系统的用户表
CREATE TABLE sales.users (...);  -- 销售系统的用户表
```

它们都叫 `users`，但因为放在不同的 schema 里，所以互不干扰

### 层次结构

```plain
一个数据库（database）
│
├── schema1
│   ├── table1
│   ├── view1
│
├── schema2
│   ├── table1（同名也可以）
│   ├── function1
```

**默认的 schema 是 public**

如果你不写 schema 名，postgres 默认放到 `public` 里：

```sql
CREATE TABLE test (id INT);
-- 实际上等价于：
CREATE TABLE public.test (id INT);
```

### 常用操作

创建 schema
```sql
CREATE SCHEMA my_schema;
```

使用 schema 中的对象
```sql
SELECT * FROM my_schema.users;
```

删除 schema
```sql
DROP SCHEMA my_schema CASCADE;
```

改变搜索路径（影响默认 schema 查找）
```sql
SET search_path TO my_schema, public;
```

这会让你查询 `SELECT * FROM users;` 时，先在 `my_schema` 中找 `users` 表，再到 `public`

**Schema 的实际用途**

| 用途                       | 说明                                                              |
| -------------------------- | ----------------------------------------------------------------- |
| 命名隔离                   | 不同模块/应用可以使用相同表名而不冲突                             |
| 权限管理                   | 可以给不同 schema 设置不同的访问权限                              |
| 多租户系统（multi-tenant） | 每个租户一个 schema，隔离数据                                     |
| 扩展管理                   | postgres 的扩展经常安装在 `pg_catalog` 或 `extension_name` schema |


**Schema 与权限控制**

你可以对 schema 本身设置访问权限：

```sql
-- 只允许某用户访问某个 schema
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA finance TO bob;
```

其中：

+ `USAGE` 权限：可以访问 schema 中的对象
+ `CREATE` 权限：可以在 schema 中新建对象

[返回目录](#目录)

## 表分区

### 简介
在 postgres 里，表分区是一种把一张大表按某个规则拆成多个更小、更易管理的分区表的技术，这些分区对用户看起来还是一张表

这样做的核心目的是提高查询性能、减少维护成本，特别是当表非常大时

### 基本原理

* 你定义一个分区表，它是一个逻辑表，自己不存数据
* 每个分区是一张独立的物理表，用于存储符合特定条件的行
* postgres 根据分区键自动把插入的数据路由到对应的分区
* 查询时，PG 会分区裁剪，只扫描相关的分区，减少 I/O

### 分区类型

| 分区方式 | 适用场景               | 示例                               |
| -------- | ---------------------- | ---------------------------------- |
| 范围分区 | 按时间、数值范围拆分   | 按 `order_date` 按月分区           |
| 列表分区 | 按离散值分类           | 按 `region` 分区（华北/华南/华东） |
| 哈希分区 | 均匀分布数据，避免热点 | 按 `user_id` 哈希到 N 个分区       |

### 示例：日期范围分区

```sql
-- 创建父表
CREATE TABLE orders (
    id serial,
    order_date date NOT NULL,
    customer_id int,
    amount numeric
) PARTITION BY RANGE (order_date);

-- 创建分区表
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE orders_2024_q3 PARTITION OF orders
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');
```

查询 `orders` 时，PG 会自动只访问符合条件的分区

### 注意事项

- 父表不存数据

   * 分区表（父表）是个逻辑表，不能直接 `INSERT` 数据到它。
   * 必须通过分区键，让数据落到对应的分区里。

- 主键唯一约束限制

   * 如果父表有 `PRIMARY KEY` 或 `UNIQUE` 约束，分区键必须包含在其中。
   * 原因：PostgreSQL 不能跨多个分区检查唯一性（除非用全局唯一索引，但 PG 原生不支持）。

- 跨分区约束不支持

   * 外键不能跨分区引用父表的数据（PostgreSQL 15 开始对外键支持有增强，但仍有限制）
   * 检查约束（CHECK）只能在分区内生效，不能全局作用

- 索引是分区本地的

   * 父表上的索引只是一个“模板”，真正的数据索引要在每个分区单独维护
   * 没有“全局索引”，这会影响某些唯一性和查询优化

- 触发器限制

   * 父表不能有行级触发器（`BEFORE` / `AFTER` ROW），只能在分区上定义
   * 语句级触发器（`STATEMENT`）可以放在父表

- 不能直接更新分区键

   * 如果更新会导致行移动到另一个分区，会报错，必须先删除再插入

### 容易踩坑的细节

这些不是硬限制，但会带来性能或维护问题：

1. **分区数量过多**

   * 每多一个分区，PG 查询规划器的开销会增加（特别是 > 1000 个时）
   * 建议单表分区数控制在几百以内

2. **分区裁剪依赖常量**

   * 要让 PG 自动裁剪分区，分区键的值最好是常量或能在计划阶段推导出来的表达式
   * 如果是运行时变量（`PREPARE`/`EXECUTE` 传参），需要 PostgreSQL 11+ 才能运行时裁剪

3. **维护成本高**

   * 新增分区需要显式 `CREATE TABLE ... PARTITION OF ...`
   * 分区的索引、权限、统计信息都是独立的

4. **统计信息是分区级的**

   * 父表没有整体统计信息（PG 13+ 有一些改进，但不如普通表直观）


### 最佳实践

* 时间序列表使用 RANGE 分区最常见（按天、按月、按季度）
* 哈希分区适合大表且需要均匀分布，但不要单独用来做时间分区
* 选择查询最频繁的列作为分区键
* 尽量避免多列组合分区
  * 组合分区（如 RANGE+HASH）可用，但增加维护复杂度
* 分区键尽量不可更新
  * 更新分区键会导致行迁移，性能差且可能报错

**索引要在分区上单独创建**
  * 父表的索引只作为模板，不会存数据
  * 可考虑为每个分区建立索引，减少索引维护压力

**主键与唯一约束**
  * 必须包含分区键，否则无法跨分区保证唯一性
  * 如果需要全局唯一，可以使用触发器或逻辑层保证

**创建自动化脚本或者调度任务**
  * 定期创建新分区
  * 删除或归档过期分区
  * 统计分区信息

### 权限与安全

* 权限在父表可以设置，但分区也要单独授权

```sql
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA sales TO analyst;
```

* 适合多租户场景，每个租户一个分区或 schema，权限控制清晰

[返回目录](#目录)

## 角色管理

`postgres` 的用户与权限管理是数据库安全的重要组成部分，理解其机制可以有效控制访问权限、防止数据泄露与误操作

`postgres` 中用户和组统一称为角色：

+ 用户：能登录系统的角色，带 `LOGIN` 属性
+ 组（Group）：不能登录，用来授权多个用户（不带 `LOGIN`）

> 一个 Role 可以既是用户又是组，只取决于是否有 `LOGIN` 权限
>

### 用户管理相关命令

postgres 提供了程序 createuser 和 dropuser 作为这些 SQL 命令的包装器，可以从 shell 命令行调用

- 创建角色
```sql
CREATE ROLE name; -- 创建角色

CREATE ROLE alice LOGIN PASSWORD '123456'; -- 创建可登录的用户

CREATE ROLE admin SUPERUSER LOGIN PASSWORD 'securepass'; -- 创建超级用户

CREATE ROLE dev_team; -- 创建组角色

CREATE ROLE bob LOGIN CREATEDB PASSWORD 'bobpwd'; -- 创建用户并允许创建数据库
```

- 修改角色属性
```sql
-- 赋予创建数据库权限
ALTER ROLE alice CREATEDB;

-- 修改密码
ALTER ROLE alice PASSWORD 'newpass';

-- 撤销登录权限
ALTER ROLE alice NOLOGIN;
```

- 查询角色
```sql
SELECT rolname FROM pg_roles; -- 现有角色的集合

SELECT rolname FROM pg_roles WHERE rolcanlogin; -- 查看可以登录的角色
```

- 删除角色

由于角色可以拥有数据库对象，并且可以拥有访问其他对象的权限，因此删除角色通常不仅仅是快速执行 DROP ROLE 的问题。必须首先删除该角色拥有的任何对象，或将其重新分配给其他所有者；并且必须撤销授予该角色的任何权限。

简而言之，删除曾用于拥有对象的角色的最通用方法是

```sql
DROP ROLE name; -- 删除角色
REASSIGN OWNED BY doomed_role TO successor_role;
DROP OWNED BY doomed_role;
-- repeat the above commands in each database of the cluster
DROP ROLE doomed_role;
```

### 权限控制（GRANT / REVOKE）

支持的权限类型（不同对象支持的权限不同）：
| 对象   | 权限类型                                                        |
| ------ | --------------------------------------------------------------- |
| 数据库 | `CONNECT`, `CREATE`, `TEMPORARY`                                |
| Schema | `USAGE`, `CREATE`                                               |
| 表     | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `REFERENCES`, `TRIGGER` |
| 序列   | `USAGE`, `SELECT`, `UPDATE`                                     |
| 函数   | `EXECUTE`                                                       |


- GRANT 权限
```sql
-- 授权用户对表的读写权限
GRANT SELECT, INSERT, UPDATE ON users TO alice;

-- 授权对数据库的连接权限
GRANT CONNECT ON DATABASE mydb TO alice;

-- 授权使用 schema
GRANT USAGE ON SCHEMA public TO alice;

-- 授权执行函数
GRANT EXECUTE ON FUNCTION add_user(text, text) TO alice;
```

- REVOKE 权限
```sql
-- 撤销读取权限
REVOKE SELECT ON users FROM alice;

-- 撤销对数据库的连接权限
REVOKE CONNECT ON DATABASE mydb FROM alice;
```

- 授权给组角色
```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dev_team;

-- 将用户添加到组
GRANT dev_team TO alice;
```

### 默认权限控制

默认权限
+ 所有新建对象的所有权属于创建者
+ 除非授权，其他角色无法访问

### 修改默认权限（ALTER DEFAULT PRIVILEGES）

```sql
-- 所有未来新建的表都授予 dev_team SELECT 权限
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO dev_team;
```

**对象所有权**

+ 每个表、视图、函数、序列都有一个拥有者
+ 拥有者有所有权限（即使没有显式 GRANT）
+ 可以改变所有权：

```sql
ALTER TABLE users OWNER TO bob;
```

### 安全机制与最佳实践

pg_hba.conf 配置认证方式，设置用户从哪些 IP 登录，采用什么方式：

```plain
# TYPE  DATABASE        USER            ADDRESS                 METHOD
host    all             all             0.0.0.0/0               md5
```

常见 `METHOD`：

+ `trust`：无条件允许
+ `md5`：密码认证
+ `scram-sha-256`：更安全的加密
+ `peer`：操作系统用户认证


[返回目录](#目录)

## 行安全策略

### 简介

除了通过 GRANT 提供的 SQL 标准权限系统之外，表还可以具有行安全策略，这些策略会根据用户限制哪些行可以通过普通查询返回，或者通过数据修改命令插入、更新或删除。此功能也称为行级安全性。默认情况下，表没有任何策略，因此，如果用户根据 SQL 权限系统拥有对表的访问权限，则该表中的所有行都可以平等地用于查询或更新。

当在表上启用行安全性时，所有对表的正常访问，例如选择行或修改行，都必须由行安全策略允许。（但是，表的拥有者通常不受行安全策略的约束）如果该表不存在任何策略，则会使用默认的拒绝策略，这意味着没有任何行可见或可以修改。适用于整个表的操作（如 TRUNCATE 和 REFERENCES）不受行安全性的限制。

行安全策略可以特定于命令、角色或两者。可以指定一个策略以应用于 ALL 命令，或者应用于 SELECT、INSERT、UPDATE 或 DELETE。可以将多个角色分配给给定的策略，并且应用正常的角色成员资格和继承规则。

要根据策略指定哪些行可见或可修改，则需要一个返回布尔结果的表达式。此表达式将在用户查询中的任何条件或函数之前，针对每一行进行评估。（此规则的唯一例外是 leakproof 函数，这些函数保证不会泄漏信息；优化器可能会选择在行安全检查之前应用此类函数。）表达式未返回 true 的行将不会被处理。可以指定单独的表达式，以独立控制可见的行和允许修改的行。策略表达式作为查询的一部分运行，并具有运行查询的用户的权限，尽管可以使用安全定义者函数来访问调用用户无法访问的数据。

超级用户和具有`BYPASSRLS`属性的角色在访问表时会绕过行安全系统。表的所有者通常也会绕过行安全性，但是表的所有者可以选择使用 `ALTER TABLE ... FORCE ROW LEVEL SECURITY` 来遵守行安全性。

**启用和禁用行安全性以及向表中添加策略始终只是表所有者的特权**

策略使用 `CREATE POLICY` 命令创建，使用 `ALTER POLICY` 命令修改，使用 `DROP POLICY` 命令删除。要启用和禁用给定表的行安全性，请使用 `ALTER TABLE` 命令

每个策略都有一个名称，并且可以为一个表定义多个策略。由于策略是特定于表的，因此一个表的每个策略都必须具有唯一的名称。不同的表可以具有相同名称的策略。

当多个策略应用于给定的查询时，它们会使用 OR（对于允许性策略，这是默认设置）或使用 AND（对于限制性策略）进行组合。这类似于给定角色具有其成员的所有角色的权限的规则。允许性策略和限制性策略将在下面进一步讨论

### 第一个行安全策略
对数据表启动行安全策略很简单，只需要先启用行安全策略，然后对这个表创建一个对应的策略便可以了。

```sql
CREATE TABLE accounts (manager text, company text, contact_email text);

-- 启用行安全策略
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

-- 创建策略
CREATE POLICY account_managers ON accounts TO managers
    USING (manager = current_user);
```

### 关于子句

**USING 子句**

作用：定义了 SELECT、UPDATE、DELETE 操作时，哪些行对当前用户是可见的（也就是说，行过滤条件）。

应用场景：

- 在执行 SELECT 查询时，只能看到满足 USING 条件的行。
- 在执行 UPDATE 或 DELETE 时，只能修改或删除满足 USING 条件的行。

简单理解：USING 是查询和修改时的行访问条件

**WITH CHECK 子句**

作用：定义了 INSERT 和 UPDATE 操作时，新插入或修改后的行必须满足的条件

应用场景：

- 插入新行时，必须满足 WITH CHECK 条件，否则插入失败。
- 更新已有行时，更新后的新数据必须满足 WITH CHECK 条件，否则更新失败。

简单理解：WITH CHECK 是写入和修改数据时的合法性校验条件

### 生产上的示例

- 准备工作

```sql
-- Simple passwd-file based example
CREATE TABLE passwd (
  user_name             text UNIQUE NOT NULL,
  pwhash                text,
  uid                   int  PRIMARY KEY,
  gid                   int  NOT NULL,
  real_name             text NOT NULL,
  home_phone            text,
  extra_info            text,
  home_dir              text NOT NULL,
  shell                 text NOT NULL
);

CREATE ROLE admin;  -- Administrator
CREATE ROLE bob;    -- Normal user
CREATE ROLE alice;  -- Normal user

INSERT INTO passwd VALUES
  ('admin','xxx',0,0,'Admin','111-222-3333',null,'/root','/bin/dash');
INSERT INTO passwd VALUES
  ('bob','xxx',1,1,'Bob','123-456-7890',null,'/home/bob','/bin/zsh');
INSERT INTO passwd VALUES
  ('alice','xxx',2,1,'Alice','098-765-4321',null,'/home/alice','/bin/zsh');

-- Be sure to enable row-level security on the table
ALTER TABLE passwd ENABLE ROW LEVEL SECURITY;

-- Create policies
-- Administrator can see all rows and add any rows
CREATE POLICY admin_all ON passwd TO admin USING (true) WITH CHECK (true);

-- Normal users can view all rows
CREATE POLICY all_view ON passwd FOR SELECT USING (true);

-- Normal users can update their own records, but
-- limit which shells a normal user is allowed to set
CREATE POLICY user_mod ON passwd FOR UPDATE
  USING (current_user = user_name)
  WITH CHECK (
    current_user = user_name AND
    shell IN ('/bin/bash','/bin/sh','/bin/dash','/bin/zsh','/bin/tcsh')
  );

-- Allow admin all normal rights
GRANT SELECT, INSERT, UPDATE, DELETE ON passwd TO admin;

-- Users only get select access on public columns
GRANT SELECT
  (user_name, uid, gid, real_name, home_phone, extra_info, home_dir, shell)
  ON passwd TO public;

-- Allow users to update certain columns
GRANT UPDATE
  (pwhash, real_name, home_phone, extra_info, shell)
  ON passwd TO public;
```

- 测试

让我们测试一下相关的行安全策略生效了没有

```shell
mydb=# set role admin;
SET
mydb=> table passwd;
 user_name | pwhash | uid | gid | real_name |  home_phone  | extra_info |  home_dir   |   shell
-----------+--------+-----+-----+-----------+--------------+------------+-------------+-----------
 admin     | xxx    |   0 |   0 | Admin     | 111-222-3333 |            | /root       | /bin/dash
 bob       | xxx    |   1 |   1 | Bob       | 123-456-7890 |            | /home/bob   | /bin/zsh
 alice     | xxx    |   2 |   1 | Alice     | 098-765-4321 |            | /home/alice | /bin/zsh
(3 行记录)


mydb=>  set role alice;
SET
mydb=> table passwd;
错误:  对表 passwd 权限不够
mydb=> select user_name,real_name,home_phone,extra_info,home_dir,shell from passwd;
 user_name | real_name |  home_phone  | extra_info |  home_dir   |   shell
-----------+-----------+--------------+------------+-------------+-----------
 admin     | Admin     | 111-222-3333 |            | /root       | /bin/dash
 bob       | Bob       | 123-456-7890 |            | /home/bob   | /bin/zsh
 alice     | Alice     | 098-765-4321 |            | /home/alice | /bin/zsh
(3 行记录)


mydb=> update passwd set user_name = 'joe';
错误:  对表 passwd 权限不够
mydb=> update passwd set real_name = 'Alice Doe';
UPDATE 1
mydb=> update passwd set real_name = 'John Doe' where user_name = 'admin';
UPDATE 0
mydb=> update passwd set shell = '/bin/xx';
错误:  新行违背了表"passwd"的行级安全策略
mydb=> delete from passwd;
错误:  对表 passwd 权限不够
mydb=> insert into passwd (user_name) values ('xxx');
错误:  对表 passwd 权限不够
mydb=> update passwd set pwhash = 'abc';
UPDATE 1
```

[返回目录](#目录)


## 客户端认证

认证是数据库服务器建立客户端身份的过程，并由此确定是否允许客户端应用程序（或运行客户端应用程序的用户）以所请求的数据库用户名进行连接。

postgres 提供了多种不同的客户端认证方法。用于认证特定客户端连接的方法可以根据（客户端）主机地址、数据库和用户进行选择。

**配置文件**

`pg_hba.conf` 是 postgres 中非常关键的一个配置文件，全名叫做：

> postgres Host-Based Authentication Configuration File
>

它的作用是：

> 控制谁可以连接 postgres、从哪里连接、用什么方式连接

+ 查看所在配置文件目录

```sql
SHOW hba_file;
```

**作用简述**

| 功能点       | 说明                                          |
| ------------ | --------------------------------------------- |
| 认证方式控制 | 支持密码、GSSAPI、LDAP、证书等多种认证方式    |
| 访问来源限制 | 可以限制 IP 地址或网段是否能连接 postgres     |
| 用户限制     | 可以限制哪些 postgres 用户允许访问            |
| 数据库限制   | 可以限制某些用户只允许访问某些数据库          |
| 连接类型限制 | 支持本地（`local`）或远程（`host`）连接的区分 |


**配置语法结构**

```
# TYPE  DATABASE  USER  ADDRESS        METHOD
host    mydb      alice 192.168.1.0/24 md5
```

| 字段     | 说明                                                                  |
| -------- | --------------------------------------------------------------------- |
| TYPE     | `local`（Unix socket）、`host`（IPv4）、`hostssl`（SSL）、`hostnossl` |
| DATABASE | 可为具体库名、`all`、`replication` 等                                 |
| USER     | postgres 用户名，可为具体名或 `all`                                   |
| ADDRESS  | IP 地址范围，`127.0.0.1/32`、`0.0.0.0/0` 等                           |
| METHOD   | 认证方式，比如 `trust`、`md5`、`scram-sha-256`、`peer`、`reject`      |


**常见认证方式**

| 认证方式        | 说明                                                        |
| --------------- | ----------------------------------------------------------- |
| `trust`         | 不验证密码，不安全，仅适合本地测试用                        |
| `md5`           | 要求密码验证（老式加密，常用）                              |
| `scram-sha-256` | 更强密码验证机制（推荐用）                                  |
| `peer`          | 本地连接中使用操作系统用户名作为验证（仅 `local` 类型可用） |
| `reject`        | 拒绝连接（可用于精确禁止某些 IP）                           |

**如何只允许某个 IP 访问数据库**

假设你只想允许 IP `192.168.1.100` 连接数据库，可以这样配置：

```
# 只允许 192.168.1.100 访问所有数据库，所有用户，用 md5 密码认证
host    all     all     192.168.1.100/32    md5

# 拒绝所有其他 IP 访问
host    all     all     0.0.0.0/0           reject
```

**顺序很重要！**  

postgres 会从上到下逐行匹配，匹配到第一个满足条件的规则就执行。所以允许规则要写在前面，拒绝规则写在后面。


[返回目录](#目录)


## 索引

**简介**

如果你要执行以下的SQL
```sql
SELECT content FROM test1 WHERE id = constant;
```

在没有索引的情况下，系统会扫描表里的每一条数据，以找到匹配的条目，如果test1表巨大，而数据却只有几条，那么这无疑是一个很低效的方法。但是，如果系统被指示在 id 列上维护索引，它可以使用更有效的方法来定位匹配的行。当它认为这样做比顺序表扫描更有效时，它将在查询中使用索引。

索引还可以使带有搜索条件的 UPDATE 和 DELETE 命令受益。索引还可以用于连接搜索。因此，在作为连接条件一部分的列上定义的索引也可以显着加快带有连接的查询。

要合理的设计和使用索引，不能盲目的使用，索引并非没有缺点。例如，在大表上创建索引可能需要很长时间。默认情况下，postgres 允许在创建索引的同时对表进行读取（SELECT 语句），但写入（INSERT，UPDATE，DELETE）将被阻塞，直到索引构建完成。在生产环境中，这通常是不可接受的。

**索引类型**

| 索引类型    | 适用场景/优点                                                                    | 常用操作符                                          | 是否支持排序 | 是否支持唯一约束 |
| ----------- | -------------------------------------------------------------------------------- | --------------------------------------------------- | ------------ | ---------------- |
| **B-tree**  | 默认索引类型，适用于大多数比较操作，如 `=`, `<`, `>`, `BETWEEN`, `LIKE` 前缀匹配 | `=`, `<`, `>`, `<=`, `>=`, `BETWEEN`, `LIKE 'abc%'` | 支持         | 支持             |
| **Hash**    | 仅用于等值查询，例如 `WHERE col = value`。性能略快于 B-tree，但功能受限          | `=`                                                 | 不支持       | 不支持           |
| **GIN**     | 多值字段，如数组、JSONB、全文检索（`to_tsvector`）                               | `@>`, `<@`, `?`, `@@` 等                            | 不支持       | 不支持           |
| **GiST**    | 空间数据（PostGIS）、全文检索、模糊搜索、自定义数据类型                          | 取决于实现（如 k-NN）                               | 不支持       | 不支持           |
| **SP-GiST** | 稀疏数据、高维数据、分布不均的字段（如IP地址、文本前缀树）                       | 特定操作符                                          | 不支持       | 不支持           |
| **BRIN**    | 特别适合大表的顺序插入列（如时间戳），体积小，查询范围效率高                     | 依赖顺序扫描                                        | 不支持       | 不支持           |

**表达式索引**

在 postgres 中，表达式索引是一种特殊形式的索引，它不是直接建立在某个列上，而是建立在**列的计算结果（表达式）** 上
```sql
CREATE INDEX idx_lower_name ON users (lower(name));
```
这个索引会存储 lower(name) 的结果，适用于你经常在查询中写 WHERE lower(name) = 'xxx' 的情况

**部分索引**

在 postgres 中，部分索引是一种只对表中部分行建立的索引

举个例子：

假设你有一个 `users` 表，100 万条用户记录，其中只有 5 万用户是“活跃”的（`active = true`）

如果你这样建了一个普通索引：

```sql
CREATE INDEX idx_all_users_email ON users(email);
```

这个索引会包含全部 100 万行的 email 信息 —— 体积大，查询时还得配合 `active = true` 过滤数据

但如果你建部分索引：

```sql
CREATE INDEX idx_active_users_email ON users(email) WHERE active = true;
```

这个索引只包含那 5 万条活跃用户的 email，因此：

* 索引所占用体积更小、查询速度更快
* 查询 `WHERE active = true AND email = 'xxx'` 时，能直接走这部分索引
* 对剩下的 95 万不活跃用户完全不走索引，省资源

**仅索引扫描和覆盖索引**

仅索引扫描的和覆盖索引是重要的知识，熟悉它们是写出高效SQL查询语句的关键。但是在聊他两之前，我们还需要一些前置知识。

**postgres 的存储结构**

postgres 的表和索引都是通过文件系统中的物理文件来存储的。每一个数据库对象（如表、索引等）都有自己的物理文件，文件结构和访问机制体现了 postgres 的核心架构理念。

postgres 默认采用堆表作为表的物理存储结构，它的核心特点是：数据以无特定顺序的形式直接存储在磁盘上的数据页中，每一行都独立存储，并通过一个唯一的**行指针（Tuple ID，简称 TID）** 定位。

**什么是回表**

回表指的是：

> 查询时先通过索引定位到匹配的行，但由于需要返回的字段不在索引中，因此还需要再访问一次原表来获取完整的数据

举个例子：

假设有如下表：

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    age INT,
    email TEXT
);
```

并且建立了一个索引：

```sql
CREATE INDEX idx_users_name ON users(name);
```

然后你执行以下查询：

```sql
SELECT email FROM users WHERE name = 'Alice';
```

- 数据库会使用 `idx_users_name` 索引找到 `name='Alice'` 的所有行的 **位置**（也就是行指针，称为 TID）。
- 由于 `email` 不包含在这个索引里，所以数据库需要根据这些指针再去原表中 **回表** 查询 `email` 字段的值。

回表的代价

回表相当于多了一次随机磁盘读取（或内存页访问），会增加查询的开销，尤其在匹配行较多的情况下。

仅索引扫描和覆盖索引的目的都是减少SQL查询时的磁盘随机读取。

仅索引扫描的目的是减少回表查询，我们不要查询的字段未设置索引的字段，而覆盖索引是一种设计方法，我们把我们需要查询的字段都添加索引。

查看执行计划

要确定你的查询语句是否是仅索引扫描或覆盖索引，可以使用`explain analyze` 语句查看执行计划。

```
EXPLAIN ANALYZE
SELECT col1 FROM my_table WHERE col2 = 'foo';
```

查看结果中是否有`Index Only Scan using my_index on my_table`等语句。

[返回目录](#目录)


## 显示锁定


**行级锁**

表级锁是数据库中锁机制的一种，它会锁住整个表，从而限制对该表的访问，以保证数据一致性和并发控制。

以下列表显示了可用的锁定模式以及 postgres 自动使用它们的上下文。 您还可以使用命令 LOCK 显式获取这些锁中的任何一个。 

请记住，所有这些锁定模式都是表级锁定，即使名称中包含单词 “行” 锁定模式的名称是历史遗留的。 

在某种程度上，名称反映了每个锁定模式的典型用法，但语义都是相同的。 一个锁定模式和另一个锁定模式之间的唯一真正区别是每个模式与之冲突的锁定模式集。两个事务不能同时在同一张表上持有冲突模式的锁。（但是，事务永远不会与自身冲突。例如，它可能获取 ACCESS EXCLUSIVE 锁，然后获取同一表上的 ACCESS SHARE 锁。）非冲突锁定模式可以由许多事务并发持有。特别要注意的是，某些锁定模式是自冲突的（例如，ACCESS EXCLUSIVE 锁不能一次由多个事务持有），而另一些则不是自冲突的（例如，ACCESS SHARE 锁可以由多个事务持有）。

| 锁模式                      | 描述                                              |
| --------------------------- | ------------------------------------------------- |
| ACCESS SHARE LOCK           | 查询锁，允许并发读取，阻止表被修改结构（DDL）     |
| ROW SHARE LOCK              | SELECT FOR UPDATE 等语句使用，阻止对表的结构修改  |
| ROW EXCLUSIVE LOCK          | INSERT/UPDATE/DELETE 操作获取，阻止结构修改       |
| SHARE UPDATE EXCLUSIVE LOCK | ANALYZE 使用，阻止其他会修改表数据的操作          |
| SHARE LOCK                  | 阻止其他事务修改表数据，但允许读取                |
| SHARE ROW EXCLUSIVE LOCK    | 更严格，阻止大部分并发修改                        |
| EXCLUSIVE LOCK              | 排他锁，阻止大部分操作                            |
| ACCESS EXCLUSIVE LOCK       | 最强锁，阻止所有其他操作，通常由 DDL 语句自动获得 |

举个例子：

我们先创建一张测试表（如果你还没有）：

```sql
CREATE TABLE test_lock (
    id SERIAL PRIMARY KEY,
    name TEXT
);
```

会话1
```sql
BEGIN;
LOCK TABLE test_lock IN EXCLUSIVE MODE;
-- 表被锁，阻止其他会话的写操作（INSERT、UPDATE、DELETE）
```

会话2
尝试写入
```sql
INSERT INTO test_lock (name) VALUES ('Blocked Insert');
-- 这个操作会被卡住，直到 Session 1 提交或回滚
```

会话1提交
```sql
COMMIT;
```

会话3，查看锁
```sql
SELECT
    pid,
    relation::regclass AS table,
    mode,
    granted
FROM pg_locks
JOIN pg_class ON pg_locks.relation = pg_class.oid
WHERE relname = 'test_lock';
```

八种锁的获取方式

1. `ACCESS SHARE`

```sql
SELECT * FROM my_table;
-- 自动获取，不会阻止任何操作，除了 DDL（如 ALTER）
```

2. `ROW SHARE`

```sql
SELECT * FROM my_table FOR SHARE;
-- 自动获取，允许写操作，但阻止某些 DDL
```

3. `ROW EXCLUSIVE`

```sql
INSERT INTO my_table VALUES (...);
-- 自动获取，允许并发读，阻止结构更改
```

4. `SHARE UPDATE EXCLUSIVE`

```sql
VACUUM my_table;
-- 自动获取，阻止并发写入，不阻止读取
```

5. `SHARE`

```sql
LOCK TABLE my_table IN SHARE MODE;
-- 手动加锁，允许读，不允许写（INSERT/UPDATE/DELETE）
```

6. `SHARE ROW EXCLUSIVE`

```sql
CREATE INDEX CONCURRENTLY idx_name ON my_table (col);
-- 自动获取，阻止很多操作（读写结构都受限）
```

7. `EXCLUSIVE`

```sql
LOCK TABLE my_table IN EXCLUSIVE MODE;
-- 阻止其他写操作，也限制读（FOR UPDATE），但普通 SELECT 不受阻
```

8. `ACCESS EXCLUSIVE`

```sql
LOCK TABLE my_table IN ACCESS EXCLUSIVE MODE;
-- 最强锁，阻止其他所有操作，包括 SELECT
```

**行级锁**

在 postgres 中，行级锁允许对表中的单独行进行并发访问控制，而不会锁住整个表。这使得多个事务可以安全地读取或更新同一个表中的不同记录，是 postgres 并发控制的核心机制之一。

postgres 中的行级锁种类

| 锁类型              | 获取方式                       | 会阻塞的操作类型                 | 说明                           |
| ------------------- | ------------------------------ | -------------------------------- | ------------------------------ |
| `FOR UPDATE`        | `SELECT ... FOR UPDATE`        | 其他更新/删除                    | 锁住选中行，防止别人更新或删除 |
| `FOR NO KEY UPDATE` | `SELECT ... FOR NO KEY UPDATE` | 其他带有 KEY 变化的操作          | 更弱于 `FOR UPDATE`            |
| `FOR SHARE`         | `SELECT ... FOR SHARE`         | 其他想要获得 `FOR UPDATE` 的事务 | 可共享读取                     |
| `FOR KEY SHARE`     | `SELECT ... FOR KEY SHARE`     | 更强的写锁（如 `FOR UPDATE`）    | 可用于外键约束引用             |


示例：使用行级锁阻止写入

假设有如下数据表：

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT
);
INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie');
```

会话 A：加锁某一行

```sql
BEGIN;
SELECT * FROM users WHERE id = 1 FOR UPDATE;
-- 此时 id=1 被锁住
```

会话 B：尝试更新同一行（会被阻塞）

```sql
BEGIN;
UPDATE users SET name = 'Eve' WHERE id = 1;
-- 会一直等待，直到会话 A 提交或回滚
```

会话 A 提交或回滚后：

```sql
COMMIT;
```

会话 B 才能继续执行。


* postgres 行级锁是隐式获取的：例如 `UPDATE`、`DELETE` 语句天然会为涉及的行加 `FOR UPDATE` 类型的锁。
* 行级锁不会阻止其他事务插入不同的行。
* 与表级锁不同，行级锁是细粒度控制，适合高并发环境。

**页级锁**

页级锁是 postgres 中一种较底层的锁机制，通常对用户不可见，也不常由用户显式控制。postgres 内部自动处理，用于保证数据页在访问或修改时的一致性和并发安全。

**死锁**

死锁是指多个事务互相等待对方释放锁，结果彼此都无法继续执行，最终 postgres 会检测到并中止其中一个事务。

举个例子：


准备一张测试表：

```sql
CREATE TABLE test_lock (
    id INT PRIMARY KEY,
    name TEXT
);

INSERT INTO test_lock VALUES (1, 'Alice'), (2, 'Bob');
```


会话1：

```sql
BEGIN;
-- 锁住 id = 1 的行
UPDATE test_lock SET name = 'X' WHERE id = 1;
```

会话2：

```sql
BEGIN;
-- 锁住 id = 2 的行
UPDATE test_lock SET name = 'Y' WHERE id = 2;
```

回到连接 1，尝试锁 id = 2：

```sql
UPDATE test_lock SET name = 'Z' WHERE id = 2;
-- 此处会等待
```

回到连接 2，尝试锁 id = 1：

```sql
UPDATE test_lock SET name = 'W' WHERE id = 1;
-- 此处触发死锁！postgres 会检测到死锁并终止其中一个事务
```

postgres 会检测到死锁并报错终止一个事务，例如：

```text
错误:  检测到死锁
DETAIL:  进程9436等待在事务 830上的ShareLock; 由进程3472阻塞.
进程3472等待在事务 831上的ShareLock; 由进程9436阻塞.
HINT:  详细信息请查看服务器日志.
CONTEXT:  当更新关系"test_lock"的元组(0, 1)时
```


1. 事务 1 先锁 A，再请求 B；
2. 事务 2 先锁 B，再请求 A；
3. postgres 检测到循环等待，主动终止其中一个事务。

**咨询锁**

在 postgres 中，咨询锁是一种用户控制的锁机制，允许你在应用层通过“自定义的键”来加锁资源，而不是锁具体的数据库行或表。这类锁不会被数据库自动管理，只会由开发者手动获取和释放。

咨询锁的特点

| 特点         | 描述                                                 |
| ------------ | ---------------------------------------------------- |
| 类型         | 会话级（session-level）或事务级（transaction-level） |
| 锁的目标     | 自定义的整数或 bigint 键值，不是具体数据表内容       |
| 是否自动释放 | 会话级在连接断开时释放；事务级在事务结束时释放       |
| 是否死锁检测 | 有，但取决于使用方式                                 |
| 使用场景     | 分布式任务锁、排他逻辑、限流、资源控制等             |

会话级锁（锁在整个连接上，直到 `pg_advisory_unlock` 或断开连接）

```sql
-- 获取锁（阻塞直到成功）
SELECT pg_advisory_lock(1);

-- 非阻塞获取锁（返回 true/false）
SELECT pg_try_advisory_lock(1);

-- 释放锁
SELECT pg_advisory_unlock(1);
```

事务级锁（随事务自动释放）

```sql
BEGIN;

-- 获取锁（阻塞）
SELECT pg_advisory_xact_lock(1);

-- 事务提交或回滚后，锁自动释放
COMMIT;
```

支持两个整数作为锁键（组合资源更灵活）

```sql
-- 获取复合键锁（两个 int）
SELECT pg_advisory_lock(123, 456);
```


模拟任务互斥执行

```sql
-- 连接 1：
SELECT pg_try_advisory_lock(100);  -- 返回 true，成功获取锁

-- 连接 2：
SELECT pg_try_advisory_lock(100);  -- 返回 false，已被连接 1 锁住

-- 连接 1：
SELECT pg_advisory_unlock(100);    -- 释放锁
```

[返回目录](#目录)


## 性能提示


**查询计划**

在 postgres 中，EXPLAIN 是一个查询分析工具，用于查看一条 SQL 语句的执行计划，帮助你了解查询是如何被数据库理解和执行的，从而进行性能优化。

```sql
EXPLAIN SELECT * FROM users WHERE age > 30;
```
> 这条语句不会被执行，而是返回执行计划

```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE age > 30;
```
> 这个会真正执行 SQL 并返回真实的执行时间和耗费资源，更有用

**规划器使用的统计信息**

在 postgres 中，查询规划器会根据统计信息来生成执行计划（比如是否走索引、使用嵌套循环还是哈希连接等）。这些统计信息由 postgres 自动收集，主要反映表的分布、基数、频率等特征。

规划器依赖的统计信息有哪些？

可以通过 `ANALYZE` 命令或自动维护来收集统计信息，它们存储在 `pg_statistic` 和 `pg_stats` 视图中。

表级别统计信息：

| 统计项          | 含义                    |
| --------------- | ----------------------- |
| `reltuples`     | 表中估算的行数          |
| `relpages`      | 表占用的页数            |
| `n_dead_tuples` | 死元组数（Vacuum 使用） |

> 来自系统表 `pg_class`


列级别统计信息：

> 来自系统视图 `pg_stats`

| 字段名              | 含义                                                          |
| ------------------- | ------------------------------------------------------------- |
| `null_frac`         | 该列中 NULL 的比例                                            |
| `n_distinct`        | 该列中唯一值的估算数量                                        |
| `most_common_vals`  | 出现最频繁的值（MCV）                                         |
| `most_common_freqs` | 对应 MCV 的频率                                               |
| `histogram_bounds`  | 值的分布直方图，用于估算范围条件（如 BETWEEN）                |
| `correlation`       | 相关性（值的排序程度），范围 \[-1, 1]，用于决定是否走索引扫描 |
| `avg_width`         | 平均字段宽度（以字节为单位）                                  |

查看统计信息的 SQL 示例

表统计信息：

```sql
SELECT relname, reltuples::bigint, relpages
FROM pg_class
WHERE relname = 'your_table';
```

列统计信息：

```sql
SELECT attname, null_frac, n_distinct, most_common_vals,
       histogram_bounds, correlation
FROM pg_stats
WHERE tablename = 'your_table';
```

手动更新统计信息

```sql
ANALYZE your_table;
```

或者更新整个数据库：

```sql
ANALYZE;
```

对于大数据量导入后，建议执行一次，以帮助规划器做出更优决策。

控制统计信息精度

你可以设置字段的统计目标 `n_distinct` 精度：

```sql
ALTER TABLE your_table ALTER COLUMN your_column SET STATISTICS 1000;
ANALYZE your_table;
```

默认是 `100`，设置越大越精确，但会导致收集时间和元数据体积增大。

规划器如何用这些信息？

举几个例子：

| 语句                            | 规划器参考什么                                          |
| ------------------------------- | ------------------------------------------------------- |
| `WHERE age = 30`                | `n_distinct` 和 `most_common_vals` 判断有多少行满足条件 |
| `WHERE score BETWEEN 60 AND 90` | `histogram_bounds` 估算选择率                           |
| `ORDER BY column`               | `correlation` 决定是否走 Index Scan                     |
| `JOIN` 操作                     | `n_distinct` 估算基数决定 Hash Join / Merge Join 等     |

`pg_statistic` 原始数据结构

`pg_stats` 是用户友好的视图，而 `pg_statistic` 是底层系统表，存储原始统计信息，比如：

| 字段                                    | 含义                            |
| --------------------------------------- | ------------------------------- |
| `stakind1`, `stavalues1`, `stanumbers1` | 表示第一组统计信息（MCV、频率） |
| `stakind2`, `stavalues2`, `stanumbers2` | 表示第二组（直方图）            |

它以数组形式存储，难以直接解读。


| 问题                        | 可能原因                   | 建议                                                     |
| --------------------------- | -------------------------- | -------------------------------------------------------- |
| 执行计划不走索引            | 估算选择率过低             | 执行 `ANALYZE`，检查 `n_distinct` 是否偏低               |
| 走 Seq Scan 而非 Index Scan | `correlation` 为负，表无序 | 尝试强制索引或增加 `random_page_cost`                    |
| JOIN 策略不合理             | 表基数估计偏差大           | 考虑提高统计目标，使用 `pg_stat_statements` 找出问题 SQL |

**填充数据库**

在首次填充数据库时，可能需要插入大量数据。本节包含一些关于如何使此过程尽可能高效的建议。

禁用自动提交 

当使用多个 INSERT 时，关闭自动提交并在最后只提交一次。（在普通 SQL 中，这意味着在开始时发出 BEGIN，在结束时发出 COMMIT。某些客户端库可能会在您不知情的情况下执行此操作，在这种情况下，您需要确保该库在您希望它完成时完成。）如果您允许每次插入单独提交，则 postgres 对于添加的每一行都会执行大量工作。在一个事务中执行所有插入的另一个好处是，如果插入一行失败，则会回滚直到该点插入的所有行，因此您不会陷入部分加载的数据。

使用 COPY 

使用 COPY 在一个命令中加载所有行，而不是使用一系列 INSERT 命令。COPY 命令针对加载大量行进行了优化；它不如 INSERT 灵活，但对于大型数据加载产生的开销要少得多。由于 COPY 是一个单独的命令，如果您使用此方法填充表，则无需禁用自动提交。

如果您不能使用 COPY，则可以使用 PREPARE 创建预备的 INSERT 语句，然后根据需要多次使用 EXECUTE。这避免了重复解析和规划 INSERT 的一些开销。不同的接口以不同的方式提供此功能；在接口文档中查找 “预备语句”。

请注意，即使使用 PREPARE 并且将多个插入批处理到单个事务中，使用 COPY 加载大量行几乎总是比使用 INSERT 快。

COPY 在与早期的 CREATE TABLE 或 TRUNCATE 命令在同一事务中使用时最快。在这种情况下，不需要写入 WAL，因为如果发生错误，包含新加载数据的文件无论如何都将被删除。但是，此考虑仅适用于 wal_level 为 minimal 的情况，因为所有命令都必须写入 WAL。

删除索引 

如果您要加载新创建的表，最快的方法是创建表，使用 COPY 批量加载表的数据，然后创建表所需的任何索引。在预先存在的数据上创建索引比在加载每一行时增量更新它要快。

如果要向现有表中添加大量数据，则删除索引、加载表，然后重新创建索引可能是一个好方法。当然，在索引丢失期间，其他用户的数据库性能可能会受到影响。在删除唯一索引之前也应该三思而后行，因为在索引丢失时，唯一约束提供的错误检查将丢失。

删除外键约束 

与索引一样，外键约束可以比逐行更有效地批量检查。因此，删除外键约束、加载数据和重新创建约束可能很有用。同样，在数据加载速度和约束丢失期间的错误检查之间需要权衡。

此外，当您将数据加载到具有现有外键约束的表中时，每个新行都需要在服务器的待处理触发器事件列表中添加一个条目（因为它是触发器的触发来检查该行的外键约束）。加载数百万行可能会导致触发器事件队列溢出可用内存，从而导致无法容忍的交换甚至命令的完全失败。因此，在加载大量数据时，删除和重新应用外键可能 是必要的，而不仅仅是期望的。如果暂时删除约束是不可接受的，那么唯一的其他方法可能是将加载操作拆分为较小的事务。

增加 maintenance_work_mem 

在加载大量数据时，临时增加 maintenance_work_mem 配置变量可以提高性能。这将有助于加速 CREATE INDEX 命令和 ALTER TABLE ADD FOREIGN KEY 命令。它对 COPY 本身没有太大作用，因此此建议仅在您使用上述一种或两种技术时才有用。

增加 max_wal_size 

临时增加 max_wal_size 配置变量也可以使大型数据加载更快。这是因为将大量数据加载到 postgres 中将导致检查点的发生频率高于正常检查点频率（由 checkpoint_timeout 配置变量指定）。每当发生检查点时，所有脏页都必须刷新到磁盘。通过在批量数据加载期间临时增加 max_wal_size，可以减少所需的检查点数。

禁用 WAL 归档和流复制 

当将大量数据加载到使用 WAL 归档或流复制的安装中时，在加载完成后获取新的基本备份可能比处理大量增量 WAL 数据更快。为了防止在加载时进行增量 WAL 日志记录，请通过将 wal_level 设置为 minimal，将 archive_mode 设置为 off，以及将 max_wal_senders 设置为零来禁用归档和流复制。但是请注意，更改这些设置需要服务器重新启动，并且使之前拍摄的任何基本备份都无法用于归档恢复和备用服务器，这可能会导致数据丢失。

除了避免归档器或 WAL 发送器处理 WAL 数据的时间外，这样做实际上会使某些命令更快，因为如果 wal_level 是 minimal 并且当前子事务（或顶级事务）创建或截断了他们更改的表或索引，它们根本不需要写入 WAL。（通过在末尾执行 fsync 而不是写入 WAL，它们可以更便宜地保证崩溃安全性。）

之后运行 ANALYZE 

每当您显著更改了表中数据的分布时，强烈建议运行 ANALYZE。这包括将大量数据批量加载到表中。运行 ANALYZE (或 VACUUM ANALYZE) 可确保规划器拥有关于表的最新统计信息。如果没有统计信息或统计信息过时，规划器在查询规划期间可能会做出错误的决策，导致任何具有不准确或不存在统计信息的表性能不佳。请注意，如果启用了自动清理守护进程，它可能会自动运行 ANALYZE

关于 pg_dump 的一些说明 

pg_dump 生成的转储脚本会自动应用以上几个但不是全部的指导原则。 要尽可能快地还原 pg_dump 转储，您需要手动执行一些额外的操作。（请注意，这些点适用于还原转储时，而不是在创建转储时。 无论是使用 psql 加载文本转储，还是使用 pg_restore 从 pg_dump 归档文件加载，都适用相同的要点。）

默认情况下，pg_dump 使用 COPY，并且在生成完整的模式和数据转储时，它会小心地在创建索引和外键之前加载数据。因此，在这种情况下，一些指导原则是自动处理的。 您需要做的是

为 maintenance_work_mem 和 max_wal_size 设置适当（即比正常情况大）的值。

如果使用 WAL 归档或流复制，请考虑在还原期间禁用它们。为此，请在加载转储之前将 archive_mode 设置为 off，将 wal_level 设置为 minimal，并将 max_wal_senders 设置为零。之后，将其设置回正确的值并进行全新的基本备份。

尝试 pg_dump 和 pg_restore 的并行转储和还原模式，并找到要使用的最佳并发作业数。通过 -j 选项并行转储和还原应该比串行模式提供更高的性能。

考虑是否应将整个转储还原为单个事务。为此，请将 -1 或 --single-transaction 命令行选项传递给 psql 或 pg_restore。 当使用此模式时，即使是最小的错误也会回滚整个还原，可能会丢弃数小时的处理。根据数据的相互关联程度，这可能比手动清理更好，也可能不好。 如果您使用单个事务并且关闭了 WAL 归档，则 COPY 命令将以最快的速度运行。

如果数据库服务器中有多个 CPU 可用，请考虑使用 pg_restore 的 --jobs 选项。这允许并发数据加载和索引创建。

之后运行 ANALYZE。

仅数据转储仍将使用 COPY，但它不会删除或重新创建索引，并且通常不会触及外键。因此，在加载仅数据转储时，如果要使用这些技术，则由您来删除和重新创建索引和外键。 在加载数据时增加 max_wal_size 仍然有用，但不要费心增加 maintenance_work_mem；相反，您将在之后手动重新创建索引和外键时执行此操作。并且不要忘记在完成后运行 ANALYZE

**非持久化设置**

持久性是数据库的一项功能，它保证记录已提交的事务，即使服务器崩溃或断电也是如此。然而，持久性会增加显著的数据库开销，因此，如果您的站点不需要这种保证，可以配置 postgres 以更快地运行。以下是您可以在这种情况下进行的一些配置更改以提高性能。除非下文另有说明，否则在数据库软件崩溃的情况下仍然保证持久性；只有突然的操作系统崩溃才会导致使用这些设置时存在数据丢失或损坏的风险。

- 将数据库集群的数据目录放置在内存支持的文件系统中（即，RAM磁盘）。这消除了所有的数据库磁盘 I/O，但将数据存储限制为可用内存量（以及可能的交换空间）

- 关闭 fsync；无需将数据刷新到磁盘

- 关闭 synchronous_commit；可能无需强制WAL在每次提交时写入磁盘。此设置确实会冒着事务丢失（但不会导致数据损坏）的风险，以防数据库崩溃

- 关闭 full_page_writes；无需防止部分页面写入

- 增加 max_wal_size 和 checkpoint_timeout；这会降低检查点的频率，但会增加 /pg_wal 的存储要求

- 创建未记录的表以避免WAL写入，尽管这会使表无法防崩溃


[返回目录](#目录)

## 功能扩展


**pg_stat_statements 扩展**

插件简介

`pg_stat_statements`是`postgres`官方提供的 SQL 统计与分析插件，用于记录数据库中执行的 SQL 语句的频率、耗时、IO 使用、命中率、调用次数等指标，是性能调优和瓶颈分析的重要工具

> 它可以聚合结构相同但参数不同的 SQL，提供清晰的执行统计信息

工作原理

* postgres 在查询执行阶段自动将 SQL 记录到`pg_stat_statements`内部结构中
* 插件会对每条 SQL 生成哈希值（queryid），以进行聚合
* 所有数据存储在内存中，重启数据库后可保留，除非手动清空
* 插件记录包括：调用次数、执行时间、返回行数、IO 读写等指标

安装与配置步骤

步骤 1：修改 `postgresql.conf`

```conf
shared_preload_libraries = 'pg_stat_statements'
```

步骤 2：重启数据库

```bash
-- 需要知道数据目录的位置
pg_ctl restart -D /your/data/dir;

-- 查看数据目录的位置
SHOW data_directory;
```

步骤 3：在数据库中启用扩展

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

步骤 4：查看是否启用成功

```sql
SELECT * FROM pg_extension WHERE extname = 'pg_stat_statements';
```

表结构字段说明

```sql
-- 使用psql查看
\d pg_stat_statements
-- 或者
\d+ pg_stat_statements
```

以下是常见字段说明

| 字段名                | 类型   | 含义                     |
| --------------------- | ------ | ------------------------ |
| `userid`              | oid    | 执行该 SQL 的用户 ID     |
| `dbid`                | oid    | 执行 SQL 的数据库 ID     |
| `queryid`             | bigint | SQL 的哈希 ID            |
| `query`               | text   | 标准化后的 SQL（参数化） |
| `calls`               | bigint | 执行次数                 |
| `rows`                | bigint | 总共返回的行数           |
| `total_exec_time`     | double | 总执行时间（ms）         |
| `mean_exec_time`      | double | 平均执行时间             |
| `min_exec_time`       | double | 最小执行时间             |
| `max_exec_time`       | double | 最大执行时间             |
| `stddev_exec_time`    | double | 执行时间的标准差         |
| `shared_blks_hit`     | bigint | 共享缓冲区命中次数       |
| `shared_blks_read`    | bigint | 从磁盘读共享块次数       |
| `shared_blks_dirtied` | bigint | 被修改过的共享块数       |
| `shared_blks_written` | bigint | 写入磁盘的共享块数       |
| `temp_blks_read`      | bigint | 临时块读                 |
| `temp_blks_written`   | bigint | 临时块写                 |
| `local_blks_hit`      | bigint | 本地缓冲区命中           |
| `blk_read_time`       | double | 读取块所花总时间（ms）   |
| `blk_write_time`      | double | 写块总时间（ms）         |

使用示例

示例 1：查看执行时间最多的 SQL

```sql
SELECT query, calls, total_exec_time, mean_exec_time
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 10;
```

示例 2：查看调用次数最多的 SQL

```sql
SELECT query, calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;
```

示例 3：查看平均执行时间最长的 SQL

```sql
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE calls > 10
ORDER BY mean_exec_time DESC
LIMIT 10;
```

示例 4：查看 IO 密集型 SQL

```sql
SELECT query, shared_blks_read, shared_blks_hit, blk_read_time
FROM pg_stat_statements
ORDER BY shared_blks_read DESC
LIMIT 10;
```

清空统计数据

```sql
SELECT pg_stat_statements_reset();
```

注意事项与最佳实践

| 项目     | 建议                                                           |
| -------- | -------------------------------------------------------------- |
| 内存占用 | 默认最多记录 5000 条语句，可通过 `pg_stat_statements.max` 配置 |
| 性能开销 | 插件有少量开销（微秒级），建议在生产环境启用，利远大于弊       |
| 精准度   | SQL 参数会被归一化（? 占位），无法区分不同值，但可判断结构性能 |
| 聚合方式 | 结构相同 SQL 会聚合，可结合 `queryid` 与日志进一步分析         |

权限要求

查询 `pg_stat_statements`：

* 需要超级用户权限，或者被授予`pg_read_all_stats`角色

```sql
GRANT pg_read_all_stats TO your_user;
```

相关参数配置

在 `postgresql.conf` 中：

```conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.max = 10000           # 默认 5000，最大记录条数
pg_stat_statements.track = all           # 表示收集什么 SQL 执行的信息，可选 none / top / all
pg_stat_statements.track_utility = on    # 是否统计 COPY、VACUUM 等语句
pg_stat_statements.save = on             # 是否在重启后保留数据
```

[返回目录](#目录)

## 管理数据库

### 创建数据库
当你想创建一个数据库的时候，如果你已经连接到了 postgres 你可以使用：
```sql
CREATE DATABASE name;
```
创建指定`name`的数据库。当然，你也可以使用`shell`命令来创建数据库

```shell
createdb name;
```

这个命令没有什么神奇的地方，如果你没有登录，它会让你输入密码登录。它连接到postgres数据库并发出CREATE DATABASE命令

### 模板数据库

`CREATE DATABASE`实际上是通过复制现有数据库来工作的。默认情况下，它会复制名为`template1`的标准系统数据库。 因此，该数据库是创建新数据库的模板。如果向`template1`添加对象，这些对象将被复制到随后创建的用户数据库中。此行为允许对数据库中的标准对象集进行站点本地修改。例如，如果在 template0 中安装了过程语言 PL/Perl，它将自动在用户数据库中可用，而无需在创建这些数据库时采取任何额外操作

但是，CREATE DATABASE 不会复制附加到源数据库的数据库级 GRANT 权限。新数据库具有默认的数据库级权限

还有一个名为`template0`的第二个标准系统数据库。 此数据库包含与`template1`的初始内容相同的数据，即只有您的 PostgreSQL 版本预定义的标准对象。template0 在数据库集群初始化后不应进行任何更改。通过指示 CREATE DATABASE 复制 template0 而不是 template1，您可以创建一个“原始”用户数据库（其中不存在任何用户定义的对象，并且系统对象没有被更改），其中不包含 template1 中的任何站点本地添加。当还原 pg_dump 转储时，这特别方便：转储脚本应还原到原始数据库中，以确保重新创建转储数据库的正确内容，而不会与可能在以后添加到 template1 的对象冲突

复制 template0 而不是 template1 的另一个常见原因是，在复制 template0 时可以指定新的编码和区域设置，而 template1 的副本必须使用相同的设置。这是因为 template1 可能包含特定于编码或区域设置的数据，而 template0 已知不包含

要通过复制 template0 创建数据库，请使用
```sql
CREATE DATABASE dbname TEMPLATE template0;
```

或者`shell`命令

```shell
createdb -T template0 dbname
```

可以创建其他模板数据库，事实上，可以通过将集群中任何数据库的名称指定为 CREATE DATABASE 的模板来复制该数据库。但重要的是要理解，这（还）不打算作为通用的 “COPY DATABASE”工具。主要的限制是，在复制源数据库时，不能有其他会话连接到该数据库。CREATE DATABASE 如果在启动时存在任何其他连接，则会失败；在复制操作期间，会阻止与源数据库的新连接

在 pg_database 中，每个数据库都有两个有用的标志：datistemplate 和 datallowconn 列。datistemplate 可以设置为指示数据库旨在作为 CREATE DATABASE 的模板。如果设置了此标志，则任何具有 CREATEDB 权限的用户都可以克隆该数据库；如果未设置，则只有超级用户和数据库的所有者可以克隆该数据库。如果 datallowconn 为 false，则不允许与该数据库建立任何新连接（但现有会话不会因为简单地设置该标志为 false 而终止）。template0 数据库通常标记为 datallowconn = false，以防止其被修改。template0 和 template1 都应始终标记为 datistemplate = true

> template1 和 template0 除了 template1 的名称是 CREATE DATABASE 的默认源数据库名称这一事实之外，没有任何特殊状态。例如，可以删除 template1 并从 template0 重新创建它，而不会产生任何不良影响。如果有人不小心在 template1 中添加了一堆垃圾，则此操作可能是明智的。（要删除 template1，它必须具有 pg_database.datistemplate = false。）
> 当初始化数据库集群时，也会创建 postgres 数据库。此数据库旨在作为用户和应用程序连接的默认数据库。它只是 template1 的副本，如有必要，可以删除并重新创建

[返回目录](#返回目录)
