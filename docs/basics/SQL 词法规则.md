# SQL 词法规则

## 标识符和关键字

在 PostgreSQL 中`update`、`select` 等语句是其关键字，也就是有固定含义的词，比如`select`就是查询语句，`insert`就是插入语句。[更多关键字参考](https://www.postgresql.org/docs/18/sql-keywords-appendix.html)

在 PostgreSQL中，标识符是用来引用数据库对象的名称。简单来说，标识符就是数据库中对象的名称，在 PG 中和大部分编程语言一样，标识符只能以字母、下划线、数字组成，且不能以数字开头。

## 常量

在 PG 中有三种类型的常量，字符串常量、位串和数字。

- 字符串常量

```sql
SELECT 'foo'
'bar';

SELECT 'foobar';
```

PostgrSQL 使用单引号表示字符串，也可以使用美元引用来表示多行字符串。
```sql
SELECT $$This is a
multi-line
string.$$;

-- This is a
-- multi-line
-- string.
```

## 操作符
在 PostgreSQL 中，操作符是用于对数据库中存储的数据进行操作的符号或关键字。它们允许你执行各种计算和操作，类似于加法、减法、比较、逻辑运算等。操作符通常用于 SQL 查询的 SELECT、WHERE、UPDATE 等语句中。

```sql
SELECT 1 + 1;
```
