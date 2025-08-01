<div align="center">
<img src="https://cdn.jsdelivr.net/gh/xxrBear/image//Hugo/202505152126346.png" height="200"/>
</div>

<h2>目录</h2>

- [安装数据库](#安装数据库)
- [SQL 风格](#sql-风格)
- [查看运行参数](#查看运行参数)
- [自定义运行参数](#自定义运行参数)
- [常用数据类型](#常用数据类型)
- [常用函数](#常用函数)
- [连接语句](#连接语句)
- [事务处理](#事务处理)
- [触发器](#触发器)
- [存储过程](#存储过程)
- [模式管理](#模式管理)
- [角色管理](#角色管理)
- [客户端认证](#客户端认证)
- [索引](#索引)
- [显示锁定](#显示锁定)
- [性能提示](#性能提示)


## 安装数据库

推荐使用官方安装包，前往[下载页](https://www.postgres.org/download/)下载对应系统的安装包

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
[返回顶部](#top)

</details>

## 查看运行参数
<details>
<summary>点击展开</summary>
</br>
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
[返回顶部](#top)
</details>

## 自定义运行参数

<details>
<summary>点击展开</summary>
</br>
postgres 安装后的默认配置通常并不适合生产环境的高性能需求，默认配置为了兼容低配置机器（如 512MB 内存的老机器），保守设置

推荐使用：[PGTune](https://pgtune.leopard.in.ua/)

输入参数，直接复制配置参数

查看PG服务配置文件所在位置
```sql
SHOW config_file;
```

修改配置文件并保存，重启数据库

[返回顶部](#top)

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

[返回顶部](#top)

</details>


## 常用函数

<details>
<summary>点击展开</summary>
</br>

**字符串函数**

长度、截取、拼接
```sql
SELECT LENGTH('hello');       -- 5  获取字符串长度

SELECT LEFT('postgres', 4); -- 'Post'  获取左侧 4 个字符

SELECT RIGHT('postgres', 4);-- 'SQL'   获取右侧 4 个字符

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

[返回顶部](#top)

</details>

## 连接语句 
<details>
<summary>
点击展开    
</summary>
</br>

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

[返回顶部](#top)

</details>

## 事务处理

<details>
<summary>点击展开</summary>
</br>

postgres 事务处理（Transaction Processing）是指在数据库中执行一系列 SQL 语句，使其成为一个不可分割的操作单元，即 要么全部执行成功，要么全部回滚，以确保数据的一致性和完整性

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

postgres 不真正支持 **读未提交** 这个级别，而是当作 **读已提交**处理

即，就算你设置了这个级别，PG 数据库还是会使用 **读已提交** 级别事务隔离

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

> 注意：我的 navacat17 版本，一个查询页面执行的语句是同一个事务，所以想让上面语句生效，你可能需要开启两个查询页面，分别执行事务 1 和 2
>

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

**问题**：事务 1 在开始时认为 `users` 里数据为 3，但在事务进行中，别的事务插入了一条数据，事务 1 重新查询时，发现数据数量变了，这就是**幻读**！

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

假设你希望：**总工资不能超过 10000**

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

postgres 发现两个事务虽然在一开始都看到工资小于 10000，但同时插入后将违反业务逻辑（工资总额实际超过了），所以**强制中止一个事务来防止幻读**

> 这就是事务隔离级别 `SERIALIZABLE` 的意义：**在并发读写逻辑上模拟串行操作，保护业务语义的一致性。**

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

[返回顶部](#top)

</details>

## 触发器

<details>
    <summary>点击展开</summary>

postgres 的触发器 Trigger 是一类特殊的数据库对象，在表的 INSERT、UPDATE 或 DELETE 事件发生时，自动执行预定义的函数（触发器函数）。它常用于 数据完整性约束、审计日志、自动计算、复杂的业务逻辑处理等场景

**触发器的构成**

一个完整的触发器由两个部分组成：

- 触发器函数（Trigger Function）：触发器执行的具体逻辑，必须返回 `TRIGGER` 类型
- 触发器（Trigger）：绑定到表的某个事件上，调用触发器函数

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

+ 行级触发器（FOR EACH ROW）：对受影响的每一行数据触发一次
+ 语句级触发器（FOR EACH STATEMENT）：对整个 SQL 语句仅触发一次

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

有时我们不希望某些重要数据被删除，可以通过`BEFORE DELETE`**触发器阻止删除**

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

[返回顶部](#top)

</details>

## 存储过程

<details>
<summary>点击展开</summary>

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

[返回顶部](#top)

</details>

## 模式管理
<details>
<summary>点击展开</summary>

在 postgres 中，模式（schema）是一个逻辑命名空间，用来组织数据库中的对象，比如表、视图、函数、类型等

> schema 就像数据库里的“文件夹”或“命名空间”，用来隔离和管理不同的数据库对象，防止命名冲突
>

**举个例子说明**

假设你有两个团队在开发两个系统，他们都需要一个叫 `users` 的表：

```sql
CREATE SCHEMA hr;
CREATE SCHEMA sales;

CREATE TABLE hr.users (...);     -- 人力资源系统的用户表
CREATE TABLE sales.users (...);  -- 销售系统的用户表
```

它们都叫 `users`，但因为放在不同的 schema 里，所以互不干扰

**postgres 中的层次结构**

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

**常用操作**

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

[返回顶部](#top)

</details>

## 角色管理

<details>
<summary>点击展开</summary>

postgres 的用户与权限管理是数据库安全的重要组成部分，理解其机制可以有效控制访问权限、防止数据泄露与误操作


postgres中用户和组统一称为角色：

+ 用户：能登录系统的角色，带 `LOGIN` 属性
+ 组（Group）：不能登录，用来授权多个用户（不带 `LOGIN`）

> 一个 Role 可以既是用户又是组，只取决于是否有 `LOGIN` 权限
>

**用户管理相关命令**

postgres 提供了程序 createuser 和 dropuser 作为这些 SQL 命令的包装器，可以从 shell 命令行调用

创建角色
```sql
CREATE ROLE name; -- 创建角色

CREATE ROLE alice LOGIN PASSWORD '123456'; -- 创建可登录的用户

CREATE ROLE admin SUPERUSER LOGIN PASSWORD 'securepass'; -- 创建超级用户

CREATE ROLE dev_team; -- 创建组角色

CREATE ROLE bob LOGIN CREATEDB PASSWORD 'bobpwd'; -- 创建用户并允许创建数据库
```

修改角色属性
```sql
-- 赋予创建数据库权限
ALTER ROLE alice CREATEDB;

-- 修改密码
ALTER ROLE alice PASSWORD 'newpass';

-- 撤销登录权限
ALTER ROLE alice NOLOGIN;
```

查询角色
```sql
SELECT rolname FROM pg_roles; -- 现有角色的集合

SELECT rolname FROM pg_roles WHERE rolcanlogin; -- 查看可以登录的角色
```

删除角色

由于角色可以拥有数据库对象，并且可以拥有访问其他对象的权限，因此删除角色通常不仅仅是快速执行 DROP ROLE 的问题。必须首先删除该角色拥有的任何对象，或将其重新分配给其他所有者；并且必须撤销授予该角色的任何权限。

简而言之，删除曾用于拥有对象的角色的最通用方法是

```sql
DROP ROLE name; -- 删除角色
REASSIGN OWNED BY doomed_role TO successor_role;
DROP OWNED BY doomed_role;
-- repeat the above commands in each database of the cluster
DROP ROLE doomed_role;
```

**权限控制（GRANT / REVOKE）**

支持的权限类型（不同对象支持的权限不同）：
| 对象   | 权限类型                                                        |
| ------ | --------------------------------------------------------------- |
| 数据库 | `CONNECT`, `CREATE`, `TEMPORARY`                                |
| Schema | `USAGE`, `CREATE`                                               |
| 表     | `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `REFERENCES`, `TRIGGER` |
| 序列   | `USAGE`, `SELECT`, `UPDATE`                                     |
| 函数   | `EXECUTE`                                                       |


GRANT 权限
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

REVOKE 权限
```sql
-- 撤销读取权限
REVOKE SELECT ON users FROM alice;

-- 撤销对数据库的连接权限
REVOKE CONNECT ON DATABASE mydb FROM alice;
```

授权给组角色
```sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dev_team;

-- 将用户添加到组
GRANT dev_team TO alice;
```

**默认权限控制**

默认权限
+ 所有新建对象的所有权属于创建者
+ 除非授权，其他角色无法访问

**修改默认权限（ALTER DEFAULT PRIVILEGES）**

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

**安全机制与最佳实践**

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


[返回顶部](#top)

</details>

## 客户端认证

<details>
<summary>点击展开</summary>
</br>

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


[返回顶部](#top)

</details>

## 索引
<details>
<summary>点击展开</summary>
</br>

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

[返回顶部](#top)

</details>

## 显示锁定

<details>
<summary>点击展开</summary>

</br>

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

[返回顶部](#top)

</details>

## 性能提示

<details>
<summary>点击展开</summary>

**查询计划**

在 postgres 中，EXPLAIN 是一个查询分析工具，用于查看一条 SQL 语句的执行计划，帮助你了解查询是如何被数据库理解和执行的，从而进行性能优化。

```sql
EXPLAIN SELECT * FROM users WHERE age > 30;
```
- 这条语句不会被执行，而是返回执行计划

```sql
EXPLAIN ANALYZE SELECT * FROM users WHERE age > 30;
```
- 这个会真正执行 SQL 并返回真实的执行时间和耗费资源，更有用

**规划器使用的统计信息**

在 PostgreSQL 中，**查询规划器（Planner）** 会根据 **统计信息（Statistics）** 来生成执行计划（比如是否走索引、使用嵌套循环还是哈希连接等）。这些统计信息由 PostgreSQL 自动收集，主要反映表的分布、基数、频率等特征。


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

---

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

当使用多个 INSERT 时，关闭自动提交并在最后只提交一次。（在普通 SQL 中，这意味着在开始时发出 BEGIN，在结束时发出 COMMIT。某些客户端库可能会在您不知情的情况下执行此操作，在这种情况下，您需要确保该库在您希望它完成时完成。）如果您允许每次插入单独提交，则 PostgreSQL 对于添加的每一行都会执行大量工作。在一个事务中执行所有插入的另一个好处是，如果插入一行失败，则会回滚直到该点插入的所有行，因此您不会陷入部分加载的数据。

使用 COPY 

使用 COPY 在一个命令中加载所有行，而不是使用一系列 INSERT 命令。COPY 命令针对加载大量行进行了优化；它不如 INSERT 灵活，但对于大型数据加载产生的开销要少得多。由于 COPY 是一个单独的命令，如果您使用此方法填充表，则无需禁用自动提交。

如果您不能使用 COPY，则可以使用 PREPARE 创建预备的 INSERT 语句，然后根据需要多次使用 EXECUTE。这避免了重复解析和规划 INSERT 的一些开销。不同的接口以不同的方式提供此功能；在接口文档中查找 “预备语句”。

请注意，即使使用 PREPARE 并且将多个插入批处理到单个事务中，使用 COPY 加载大量行几乎总是比使用 INSERT 快。

COPY 在与早期的 CREATE TABLE 或 TRUNCATE 命令在同一事务中使用时最快。在这种情况下，不需要写入 WAL，因为如果发生错误，包含新加载数据的文件无论如何都将被删除。但是，此考虑仅适用于 wal_level 为 minimal 的情况，因为所有命令都必须写入 WAL。

删除索引 

如果您要加载新创建的表，最快的方法是创建表，使用 COPY 批量加载表的数据，然后创建表所需的任何索引。在预先存在的数据上创建索引比在加载每一行时增量更新它要快。

如果要向现有表中添加大量数据，则删除索引、加载表，然后重新创建索引可能是一个好方法。当然，在索引丢失期间，其他用户的数据库性能可能会受到影响。在删除唯一索引之前也应该三思而后行，因为在索引丢失时，唯一约束提供的错误检查将丢失。

删除外键约束 

与索引一样，外键约束可以比逐行更有效地 “批量” 检查。因此，删除外键约束、加载数据和重新创建约束可能很有用。同样，在数据加载速度和约束丢失期间的错误检查之间需要权衡。

此外，当您将数据加载到具有现有外键约束的表中时，每个新行都需要在服务器的待处理触发器事件列表中添加一个条目（因为它是触发器的触发来检查该行的外键约束）。加载数百万行可能会导致触发器事件队列溢出可用内存，从而导致无法容忍的交换甚至命令的完全失败。因此，在加载大量数据时，删除和重新应用外键可能 是必要的，而不仅仅是期望的。如果暂时删除约束是不可接受的，那么唯一的其他方法可能是将加载操作拆分为较小的事务。

增加 maintenance_work_mem 

在加载大量数据时，临时增加 maintenance_work_mem 配置变量可以提高性能。这将有助于加速 CREATE INDEX 命令和 ALTER TABLE ADD FOREIGN KEY 命令。它对 COPY 本身没有太大作用，因此此建议仅在您使用上述一种或两种技术时才有用。

增加 max_wal_size 

临时增加 max_wal_size 配置变量也可以使大型数据加载更快。这是因为将大量数据加载到 PostgreSQL 中将导致检查点的发生频率高于正常检查点频率（由 checkpoint_timeout 配置变量指定）。每当发生检查点时，所有脏页都必须刷新到磁盘。通过在批量数据加载期间临时增加 max_wal_size，可以减少所需的检查点数。

禁用 WAL 归档和流复制 

当将大量数据加载到使用 WAL 归档或流复制的安装中时，在加载完成后获取新的基本备份可能比处理大量增量 WAL 数据更快。为了防止在加载时进行增量 WAL 日志记录，请通过将 wal_level 设置为 minimal，将 archive_mode 设置为 off，以及将 max_wal_senders 设置为零来禁用归档和流复制。但是请注意，更改这些设置需要服务器重新启动，并且使之前拍摄的任何基本备份都无法用于归档恢复和备用服务器，这可能会导致数据丢失。

除了避免归档器或 WAL 发送器处理 WAL 数据的时间外，这样做实际上会使某些命令更快，因为如果 wal_level 是 minimal 并且当前子事务（或顶级事务）创建或截断了他们更改的表或索引，它们根本不需要写入 WAL。（通过在末尾执行 fsync 而不是写入 WAL，它们可以更便宜地保证崩溃安全性。）

14.4.8. 之后运行 ANALYZE 
每当您显著更改了表中数据的分布时，强烈建议运行 ANALYZE。这包括将大量数据批量加载到表中。运行 ANALYZE (或 VACUUM ANALYZE) 可确保规划器拥有关于表的最新统计信息。如果没有统计信息或统计信息过时，规划器在查询规划期间可能会做出错误的决策，导致任何具有不准确或不存在统计信息的表性能不佳。请注意，如果启用了自动清理守护进程，它可能会自动运行 ANALYZE；有关更多信息，请参阅第 24.1.3 节和第 24.1.6 节。

关于 pg_dump 的一些说明 

pg_dump 生成的转储脚本会自动应用以上几个但不是全部的指导原则。 要尽可能快地还原 pg_dump 转储，您需要手动执行一些额外的操作。（请注意，这些点适用于还原转储时，而不是在创建转储时。 无论是使用 psql 加载文本转储，还是使用 pg_restore 从 pg_dump 归档文件加载，都适用相同的要点。）

默认情况下，pg_dump 使用 COPY，并且在生成完整的模式和数据转储时，它会小心地在创建索引和外键之前加载数据。因此，在这种情况下，一些指导原则是自动处理的。 您需要做的是

为 maintenance_work_mem 和 max_wal_size 设置适当（即比正常情况大）的值。

如果使用 WAL 归档或流复制，请考虑在还原期间禁用它们。为此，请在加载转储之前将 archive_mode 设置为 off，将 wal_level 设置为 minimal，并将 max_wal_senders 设置为零。之后，将其设置回正确的值并进行全新的基本备份。

尝试 pg_dump 和 pg_restore 的并行转储和还原模式，并找到要使用的最佳并发作业数。通过 -j 选项并行转储和还原应该比串行模式提供更高的性能。

考虑是否应将整个转储还原为单个事务。为此，请将 -1 或 --single-transaction 命令行选项传递给 psql 或 pg_restore。 当使用此模式时，即使是最小的错误也会回滚整个还原，可能会丢弃数小时的处理。根据数据的相互关联程度，这可能比手动清理更好，也可能不好。 如果您使用单个事务并且关闭了 WAL 归档，则 COPY 命令将以最快的速度运行。

如果数据库服务器中有多个 CPU 可用，请考虑使用 pg_restore 的 --jobs 选项。这允许并发数据加载和索引创建。

之后运行 ANALYZE。

仅数据转储仍将使用 COPY，但它不会删除或重新创建索引，并且通常不会触及外键。[14] 因此，在加载仅数据转储时，如果要使用这些技术，则由您来删除和重新创建索引和外键。 在加载数据时增加 max_wal_size 仍然有用，但不要费心增加 maintenance_work_mem；相反，您将在之后手动重新创建索引和外键时执行此操作。并且不要忘记在完成后运行 ANALYZE；有关更多信息，请参阅第 24.1.3 节和第 24.1.6 节。

**非持久化设置**

持久性是数据库的一项功能，它保证记录已提交的事务，即使服务器崩溃或断电也是如此。然而，持久性会增加显著的数据库开销，因此，如果您的站点不需要这种保证，可以配置 PostgreSQL 以更快地运行。以下是您可以在这种情况下进行的一些配置更改以提高性能。除非下文另有说明，否则在数据库软件崩溃的情况下仍然保证持久性；只有突然的操作系统崩溃才会导致使用这些设置时存在数据丢失或损坏的风险。

- 将数据库集群的数据目录放置在内存支持的文件系统中（即，RAM磁盘）。这消除了所有的数据库磁盘 I/O，但将数据存储限制为可用内存量（以及可能的交换空间）

- 关闭 fsync；无需将数据刷新到磁盘

- 关闭 synchronous_commit；可能无需强制WAL在每次提交时写入磁盘。此设置确实会冒着事务丢失（但不会导致数据损坏）的风险，以防数据库崩溃

- 关闭 full_page_writes；无需防止部分页面写入

- 增加 max_wal_size 和 checkpoint_timeout；这会降低检查点的频率，但会增加 /pg_wal 的存储要求

- 创建未记录的表以避免WAL写入，尽管这会使表无法防崩溃



</details>