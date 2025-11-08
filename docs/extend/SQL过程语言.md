## SQL过程语言

### 基础概念

PostgreSQL 内置的过程语言，允许在 SQL 中使用控制语句（循环、条件、变量、异常处理）

* **应用场景**

  * 封装复杂业务逻辑
  * 写存储过程和函数
  * 定义触发器逻辑
  * 数据清洗、批处理任务


### 基础语法

```sql
DO $$
DECLARE
    v_count integer := 0;
BEGIN
    v_count := v_count + 1;
    RAISE NOTICE 'Count=%', v_count;
END;
$$ LANGUAGE plpgsql;
```

**核心结构**

* **`DECLARE`**：变量、游标声明
* **`BEGIN ... END;`**：过程体
* **`RAISE`**：输出调试信息
* **`;`**：语句结束符


### 数据类型

* 支持所有 **PostgreSQL 内置类型**（数值、字符串、数组、JSON、复合类型等）
* **特殊变量类型**

  * `%TYPE`：继承某一列的类型
  * `%ROWTYPE`：继承某一表的整行结构

例：

```sql
DECLARE
    v_name employees.name%TYPE;
    v_row employees%ROWTYPE;
```

### 变量与常量

* **变量声明**

  ```sql
  DECLARE
      v_total integer := 0;
      v_price numeric(10,2);
  ```
* **常量**

  ```sql
  DECLARE
      pi CONSTANT numeric := 3.14159;
  ```

### 控制结构

**IF 条件**

```sql
IF v_total > 100 THEN
    RAISE NOTICE 'High';
ELSIF v_total > 50 THEN
    RAISE NOTICE 'Medium';
ELSE
    RAISE NOTICE 'Low';
END IF;
```

**CASE**

```sql
CASE v_status
    WHEN 'A' THEN RAISE NOTICE 'Active';
    WHEN 'I' THEN RAISE NOTICE 'Inactive';
    ELSE RAISE NOTICE 'Unknown';
END CASE;
```

**LOOP 循环**

```sql
LOOP
    EXIT WHEN v_count > 10;
    v_count := v_count + 1;
END LOOP;
```

**WHILE 循环**

```sql
WHILE v_count < 5 LOOP
    v_count := v_count + 1;
END LOOP;
```

**FOR 循环**

```sql
FOR i IN 1..10 LOOP
    RAISE NOTICE 'i=%', i;
END LOOP;
```

### 游标与结果集

**显式游标**

```sql
DECLARE
    c1 CURSOR FOR SELECT id, name FROM employees;
BEGIN
    OPEN c1;
    FETCH c1 INTO v_id, v_name;
    CLOSE c1;
END;
```

**FOR-IN 查询循环**

```sql
FOR r IN SELECT id, name FROM employees LOOP
    RAISE NOTICE 'Employee: %, %', r.id, r.name;
END LOOP;
```

### 函数与存储过程

**函数**

```sql
CREATE OR REPLACE FUNCTION add_numbers(a int, b int)
RETURNS int AS $$
BEGIN
    RETURN a + b;
END;
$$ LANGUAGE plpgsql;
```

### 存储过程

```sql
CREATE PROCEDURE log_event(msg text)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO logs(message, created_at) VALUES (msg, now());
END;
$$;
```

调用：

```sql
CALL log_event('test');
```

### 异常处理

```sql
BEGIN
    INSERT INTO employees(id, name) VALUES (1, 'Tom');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'ID already exists';
END;
```

常见异常：

* `unique_violation`
* `foreign_key_violation`
* `division_by_zero`
* `others`

### 触发器

```sql
CREATE OR REPLACE FUNCTION trg_audit()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(table_name, action, created_at)
    VALUES (TG_TABLE_NAME, TG_OP, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION trg_audit();
```

### 动态 SQL

```sql
EXECUTE 'INSERT INTO ' || quote_ident(tablename) || '(col) VALUES ($1)'
USING value;
```

可配合 `format()` 生成安全 SQL。

### 特殊内置变量

* `FOUND`：上一条 SQL 是否有结果
* `ROW_COUNT`：受影响行数
* `TG_OP`：触发器操作类型（INSERT/UPDATE/DELETE）
* `TG_TABLE_NAME`：触发器表名

### RAISE 消息

```sql
RAISE NOTICE 'Value=%', v_total;
RAISE WARNING 'This is warning';
RAISE EXCEPTION 'Error: %', v_error;
```

### 性能优化建议

* 使用 **批量 SQL** 代替逐行处理（避免慢的 "row by row"）
* 使用 `FOR ... IN SELECT` 而非显式游标
* 避免在循环里频繁 `EXECUTE` 动态 SQL
* 善用 `EXCEPTION` 捕获错误而不是预检测

### 最佳实践

* 用 `%TYPE`、`%ROWTYPE` 保持类型同步
* 用 `RETURN QUERY` 返回集合结果
* 触发器逻辑保持轻量（复杂逻辑放到函数中）
* 使用 `RAISE NOTICE` 调试，但生产环境减少日志输出

[返回目录](#目录)
