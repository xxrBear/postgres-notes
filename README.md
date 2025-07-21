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
- [事务处理](#事务处理)


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


</details>

## 事务处理

<details>
<summary>点击展开</summary>
</br>

**简介**

PostgreSQL 事务处理（Transaction Processing）是指在数据库中执行一系列 SQL 语句，使其成为一个不可分割的操作单元，即 要么全部执行成功，要么全部回滚，以确保数据的一致性和完整性

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

在数据库中，事务隔离级别用于控制多个事务并发执行时的可见性，避免数据不一致的问题。PostgreSQL 遵循 ACID（原子性、一致性、隔离性、持久性） 原则，并提供四种事务隔离级别

| 隔离级别         | 脏读     | 不可重复读 | 幻读     |
| ---------------- | -------- | ---------- | -------- |
| 读未提交         | 可能发生 | 可能发生   | 可能发生 |
| 读已提交（默认） | 不会发生 | 可能发生   | 可能发生 |
| 可重复读         | 不会发生 | 不会发生   | 可能发生 |
| 可串行化         | 不会发生 | 不会发生   | 不会发生 |


下面我们来逐一介绍

**读未提交/读已提交**

PostgreSQL 不真正支持 **读未提交** 这个级别，而是当作 **读已提交**处理

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

PostgreSQL 发现两个事务虽然在一开始都看到工资小于 10000，但同时插入后将违反业务逻辑（工资总额实际超过了），所以**强制中止一个事务来防止幻读**

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

在 PostgreSQL 配置文件 `postgresql.conf` 设置（全局）

```sql
default_transaction_isolation = 'read committed'
```

+ 影响所有数据库的默认隔离级别

**自动提交**

PostgreSQL 默认开启自动提交模式，即每条 SQL 语句都会被自动提交。如果要手动管理事务，需要显式使用 `BEGIN`

```sql
SET AUTOCOMMIT TO OFF;
```

</details>