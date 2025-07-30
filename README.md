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

## 自定义运行参数

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

## 触发器

<details>
    <summary>点击展开</summary>

PostgreSQL 的触发器 Trigger 是一类特殊的数据库对象，在表的 INSERT、UPDATE 或 DELETE 事件发生时，自动执行预定义的函数（触发器函数）。它常用于 数据完整性约束、审计日志、自动计算、复杂的业务逻辑处理等场景

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

PostgreSQL 触发器的创建需要两步：

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
</details>

## 存储过程

<details>
<summary>点击展开</summary>

PostgreSQL 中的存储过程，是一种在数据库中定义的可重复使用的程序单元，用于封装复杂的业务逻辑和数据处理操作，类似编程语言的函数

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

</details>

## 模式管理
<details>
<summary>点击展开</summary>

在 PostgreSQL 中，模式（schema）是一个逻辑命名空间，用来组织数据库中的对象，比如表、视图、函数、类型等

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

**PostgreSQL 中的层次结构**

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

如果你不写 schema 名，PostgreSQL 默认放到 `public` 里：

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

| 用途                       | 说明                                                                |
| -------------------------- | ------------------------------------------------------------------- |
| 命名隔离                   | 不同模块/应用可以使用相同表名而不冲突                               |
| 权限管理                   | 可以给不同 schema 设置不同的访问权限                                |
| 多租户系统（multi-tenant） | 每个租户一个 schema，隔离数据                                       |
| 扩展管理                   | PostgreSQL 的扩展经常安装在 `pg_catalog` 或 `extension_name` schema |


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

</details>

## 角色管理

<details>
<summary>点击展开</summary>

PostgreSQL 的用户与权限管理是数据库安全的重要组成部分，理解其机制可以有效控制访问权限、防止数据泄露与误操作


PostgreSQL中用户和组统一称为角色：

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

</details>

## 客户端认证

<details>
<summary>点击展开</summary>
</br>

认证是数据库服务器建立客户端身份的过程，并由此确定是否允许客户端应用程序（或运行客户端应用程序的用户）以所请求的数据库用户名进行连接。

PostgreSQL 提供了多种不同的客户端认证方法。用于认证特定客户端连接的方法可以根据（客户端）主机地址、数据库和用户进行选择。

**配置文件**

`pg_hba.conf` 是 PostgreSQL 中非常关键的一个配置文件，全名叫做：

> PostgreSQL Host-Based Authentication Configuration File
>

它的作用是：

> 控制谁可以连接 PostgreSQL、从哪里连接、用什么方式连接

+ 查看所在配置文件目录

```sql
SHOW hba_file;
```

**作用简述**

| 功能点       | 说明                                          |
| ------------ | --------------------------------------------- |
| 认证方式控制 | 支持密码、GSSAPI、LDAP、证书等多种认证方式    |
| 访问来源限制 | 可以限制 IP 地址或网段是否能连接 PostgreSQL   |
| 用户限制     | 可以限制哪些 PostgreSQL 用户允许访问          |
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
| USER     | PostgreSQL 用户名，可为具体名或 `all`                                 |
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

PostgreSQL 会从上到下逐行匹配，匹配到第一个满足条件的规则就执行。所以允许规则要写在前面，拒绝规则写在后面。

</details>
