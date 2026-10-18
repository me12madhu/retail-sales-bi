"""Generate a SYNTHETIC retail sales dataset (data/raw_sales.csv).

The data is randomly generated for practice and demonstration. It is NOT real
company data. Some messiness (duplicates, missing values, inconsistent text)
is added on purpose so the cleaning step has real work to do.
"""
import numpy as np
import pandas as pd

rng = np.random.default_rng(42)
N = 5000

catalog = {
    "Technology": {"Laptop": (55000, 0.18), "Smartphone": (22000, 0.15), "Headphones": (3000, 0.35), "Smartwatch": (8000, 0.28)},
    "Furniture": {"Office Chair": (7000, 0.30), "Study Desk": (9000, 0.26), "Bookshelf": (6000, 0.32)},
    "Office Supplies": {"Notebook Pack": (250, 0.45), "Printer Paper": (450, 0.30), "Pen Set": (150, 0.50), "Stapler": (200, 0.40)},
}
products = [(c, p, price, margin) for c, items in catalog.items() for p, (price, margin) in items.items()]
weights = np.array([1.0 if c == "Technology" else 1.3 if c == "Furniture" else 2.2 for c, *_ in products])
weights /= weights.sum()

regions = ["North", "South", "East", "West"]
region_w = [0.22, 0.34, 0.18, 0.26]
segments = ["Consumer", "Corporate", "Home Office"]
segment_w = [0.52, 0.30, 0.18]

dates = pd.to_datetime("2023-01-01") + pd.to_timedelta(rng.integers(0, 730, N), unit="D")
idx = rng.choice(len(products), N, p=weights)
rows = []
for i in range(N):
    c, p, price, margin = products[idx[i]]
    month = dates[i].month
    season = 1.0 + (0.25 if month in (10, 11, 12) else 0)
    qty = max(1, int(rng.poisson(2 * season)))
    discount = float(rng.choice([0, 0.05, 0.10, 0.20, 0.30], p=[0.45, 0.2, 0.18, 0.1, 0.07]))
    unit_price = round(price * rng.uniform(0.95, 1.05), 2)
    unit_cost = round(unit_price * (1 - margin), 2)
    rows.append({
        "order_id": f"ORD-{100000 + i}",
        "order_date": dates[i].strftime("%Y-%m-%d"),
        "customer_id": f"CUST-{rng.integers(1, 1200):04d}",
        "segment": rng.choice(segments, p=segment_w),
        "region": rng.choice(regions, p=region_w),
        "category": c, "product": p,
        "quantity": qty, "unit_price": unit_price,
        "discount": discount, "unit_cost": unit_cost,
    })
df = pd.DataFrame(rows)

# Add realistic mess for the cleaning step
df.loc[rng.choice(N, 90, replace=False), "segment"] = np.nan
df.loc[rng.choice(N, 120, replace=False), "region"] = df["region"].str.lower()
df.loc[rng.choice(N, 60, replace=False), "region"] = " " + df["region"] + " "
df = pd.concat([df, df.sample(45, random_state=1)], ignore_index=True)  # duplicate rows
df = df.sample(frac=1, random_state=7).reset_index(drop=True)

df.to_csv("data/raw_sales.csv", index=False)
print(f"Saved data/raw_sales.csv with {len(df)} rows")
