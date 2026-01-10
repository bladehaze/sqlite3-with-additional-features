# SELECT * EXCEPT(...) Implementation

This document describes the minimal, non-intrusive implementation of the `SELECT * EXCEPT(column_list)` syntax.

## Changes Made

### 1. Parser Grammar (`src/parse.y`)
- Added two new grammar rules to handle `* EXCEPT(...)` and `table.* EXCEPT(...)`
- The except list (IdList) is stored in the Expr's `x.pList` field by casting IdList* to ExprList*
- This reuses existing infrastructure without adding new fields to Expr

### 2. Column Expansion (`src/select.c`)
- Modified the column expansion loop to check for an EXCEPT clause
- When expanding `*` or `table.*`, columns in the EXCEPT list are skipped
- Works for both regular columns and rowid columns

### 3. Memory Management (`src/expr.c`)
- Modified `sqlite3ExprDeleteNN` to properly clean up IdList stored in `x.pList` for TK_ASTERISK
- When deleting a TK_ASTERISK expression, if `x.pList` is set, it's deleted as an IdList instead of ExprList

## Design Decisions

1. **Reusing x.pList**: Instead of adding a new field to Expr, we reuse `x.pList` to store the IdList. This is safe because:
   - For TK_ASTERISK, `x.pList` is normally NULL
   - We only access it in our specific code paths with proper casting
   - We handle cleanup correctly in expr.c

2. **Minimal Changes**: The implementation touches only 3 files:
   - `parse.y`: Grammar rules
   - `select.c`: Column expansion logic
   - `expr.c`: Memory cleanup

3. **Backward Compatibility**: The changes are fully backward compatible:
   - Existing `SELECT *` queries work unchanged
   - The EXCEPT keyword was already reserved (used in compound SELECTs)
   - No changes to core data structures

## Usage

```sql
-- Basic usage
SELECT * EXCEPT(columnA, columnB) FROM table;

-- With table prefix
SELECT table.* EXCEPT(columnA, columnB) FROM table;

-- Works with joins
SELECT * EXCEPT(columnA) FROM t1 JOIN t2;
```

## Testing

To test the implementation:
1. Build SQLite with the changes
2. Run queries like:
   ```sql
   CREATE TABLE t1(a, b, c, d);
   INSERT INTO t1 VALUES(1, 2, 3, 4);
   SELECT * EXCEPT(b, c) FROM t1;
   -- Should return columns a and d
   ```

## Notes

- The EXCEPT list uses case-insensitive matching (via `sqlite3IdListIndex`)
- Rowid columns can also be excluded if their alias is in the EXCEPT list
- The implementation follows SQLite's existing patterns for minimal intrusiveness

