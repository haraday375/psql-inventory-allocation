-- ========================================
-- 1. 注文ごとの貸出日カレンダーを作成
-- ========================================
WITH date_range AS (
  SELECT
    "orderID",
    "productCode",
    generate_series("shippingDate", "returnDate", interval '1 day')::date AS calendar_date,
    "qty"
  FROM "order_sample"
),

-- ========================================
-- 2. 空いている在庫から対象を抽出し、注文単位で番号を振る
-- ========================================
target_inventory AS (
  SELECT
    di."calendar_date",
    di."ProductCode",
    di."SerialNumber",
    di."orderID",
    dr."orderID" AS orderID_dr,
    dr."qty",
    ROW_NUMBER() OVER (
      PARTITION BY dr."orderID", dr."productCode"
      ORDER BY di."calendar_date", di."SerialNumber"
    ) AS rn
  FROM "daily_inventory" di
  JOIN date_range dr
    ON dr."calendar_date" = di."calendar_date"
   AND dr."productCode" = di."ProductCode"
  WHERE di."orderID" IS NULL OR di."orderID" = ''
),

-- ========================================
-- 3. 割り当て対象を抽出（注文の数量分まで）
-- ========================================
assignments AS (
  SELECT
    orderID_dr AS "orderID",
    "ProductCode" AS "productCode",
    "calendar_date",
    "SerialNumber"
  FROM target_inventory
  WHERE rn <= qty
)

-- ========================================
-- 4. 対象在庫に orderID を更新
-- ========================================
UPDATE "daily_inventory" di
SET
  "orderID" = a."orderID"
FROM assignments a
WHERE
  di."ProductCode" = a."productCode"
  AND di."calendar_date" = a."calendar_date"
  AND di."SerialNumber" = a."SerialNumber";
