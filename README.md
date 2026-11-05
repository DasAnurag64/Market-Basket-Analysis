[market_basket_analysis_readme.md](https://github.com/user-attachments/files/34451369/market_basket_analysis_readme.md)
# Retail Market Basket Analysis & Product Affinity Engine

An end-to-end transaction affinity pipeline built with **SQL Server** and an interactive **Executive Decision Dashboard** deployed in **Microsoft Excel**.

This project mines co-purchase patterns across 20,000+ transaction events to uncover hidden product associations, identify natural cross-category bridge opportunities, and calculate statistical rule metrics (**Support**, **Confidence**, and **Lift**) to inform bundle merchandising and checkout recommendation engines.

## 📌 Executive Summary & Key Insights

Rather than evaluating sales volume in silos, this project quantifies co-occurrence behaviors:

1. **Volume Driver (The Core Bundle):**
   * **`Pathani Kurta Classic + Leather Kolhapuri Mojari`** led overall transaction frequency with **703 co-purchases** (~8.27% support). This pair acts as the anchor bundle for high-frequency lifestyle marketing.

2. **Recommendation Engine Driver (Maximum Cross-Sell Lift):**
   * **`Cotton Casual Shirt → Leather Formal Belt`** delivered the project's highest lift (**5.17**) with an associated basket confidence of **63.61%**. Because the lift far exceeds 1.0, this rule proves an organic behavioral affinity rather than random chance, making it the highest-priority rule for checkout recommendation carousels.

3. **Cross-Category Bridges:**
   * Evaluating the affinity matrix revealed that **Fashion & Apparel** and **Footwear & Essentials** generated mutual co-purchases exceeding **2,400+ transactions**, establishing an empirical case for bundled promotional discounts across traditionally separated retail departments.

## 📊 Dashboard Visual Architecture

The interactive dashboard consolidates transaction metrics, statistical thresholds, and matrix visualizations into a unified decision canvas:

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│  EXECUTIVE KPI SUMMARY CARDS                                                     │
│  [Top Bundle: Pathani + Mojari] [Max Pair Volume: 703] [Total Events: 19,988]    │
│  [Top Category: Fashion & Apparel] [Max Lift: 5.17]   [Avg Confidence: 11.1%]    │
└───────────────────────────────────┬──────────────────────────────────────────────┘
                                    │
         ┌──────────────────────────┴──────────────────────────┐
         ▼                                                     ▼
┌──────────────────────────────────────┐     ┌─────────────────────────────────────┐
│  Top 10 Bundles by Raw Volume        │     │  Top 10 Association Rules by Lift   │
│  (Horizontal Bar Chart - Volume)     │     │  (Horizontal Bar Chart - Power)     │
└──────────────────┬───────────────────┘     └──────────────────┬──────────────────┘
                   │                                            │
         ┌─────────┴────────────────────────────────────────────┴─────────┐
         ▼                                                                ▼
┌──────────────────────────────────────┐     ┌─────────────────────────────────────┐
│  Cross-Category Affinity Matrix      │     │  Rule Strength: Confidence vs. Lift │
│  (Pivot Table + Gradient Heatmap)    │     │  (Full Distribution Scatter Plot)   │
└──────────────────────────────────────┘     └─────────────────────────────────────┘
```

### Dashboard Components:
* **Executive Metric Tiles:** Displays high-level transaction volume, peak association thresholds, and basket baselines without visual noise.
* **Co-Purchased Bundle Volume:** Ranks pair combinations to separate mass staples from niche combinations.
* **Association Rules by Lift:** Pinpoints asymmetric directional rules ($A \rightarrow B$) prioritized by conversion impact.
* **Category-to-Category Affinity Heatmap:** A two-way matrix mapping transaction intensity across retail categories, color-scaled to surface departmental bridge opportunities.
* **Confidence vs. Lift Scatter Plot:** Visualizes the entire association rule population; points clustered in the upper-right quadrant ($\text{Lift} > 4.5$, $\text{Confidence} > 50\%$) isolate high-yield recommendation candidates.

## 🧮 Statistical Foundation & Rule Metrics

Every candidate rule $A \rightarrow B$ is evaluated across three core association parameters:

$$
\text{Support}(A \rightarrow B) = \frac{\text{Transactions containing both } A \text{ and } B}{\text{Total Transactions}}
$$

$$
\text{Confidence}(A \rightarrow B) = \frac{P(A \cap B)}{P(A)} = \frac{\text{Support}(A \cup B)}{\text{Support}(A)}
$$

$$
\text{Lift}(A \rightarrow B) = \frac{\text{Confidence}(A \rightarrow B)}{\text{Expected Support}(B)} = \frac{P(A \cap B)}{P(A) \cdot P(B)}
$$

* **Interpretation of Lift:**
  * $\text{Lift} = 1$: Items $A$ and $B$ are completely independent.
  * $\text{Lift} < 1$: Negative association; purchasing $A$ makes purchasing $B$ less likely.
  * $\text{Lift} > 1$: Positive association. In our dataset, high-lift pairs ($5.17$, $4.98$) indicate pairs that are purchased together more than 5x as often as expected by random chance.

## 🛠️ Data Pipeline & SQL Architecture

The analysis was performed against transaction logs using SQL window functions, self-joins, and aggregations.

### Query 1: Pair Frequency & Co-Occurrence Matrix
* Self-joins line-item records on identical `OrderID` where `ProductID_A < ProductID_B` to prevent reflexive ($A = A$) and duplicate inverse pairs ($B + A$).
* Aggregates total co-occurrence counts and assigns rank partitioning across category pairs.

### Query 2: Support, Confidence, and Lift Metrics Engine
* Computes discrete support per product using common table expressions (`WITH Basket_Totals AS (...)`).
* Calculates individual conditional probabilities to output asymmetric association rules ($A \rightarrow B$ vs. $B \rightarrow A$).
* Applies threshold filters ($\text{Support} \ge 0.5\%$, $\text{Min Frequency} \ge 30$) to eliminate rare spurious transactions before computing Lift.

## 📁 Repository Structure

```
├── data/
│   ├── query1_co_purchase_pairs.csv    # Co-occurrence counts & category tagging
│   └── query2_association_rules.csv    # Support, Confidence, & Lift calculations
├── sql/
│   ├── 01_co_purchase_aggregation.sql  # Self-join pair frequency logic
│   └── 02_market_basket_metrics.sql    # Support, Confidence & Lift mining script
├── dashboard/
│   ├── screenshots/                    # High-res exports of Excel dashboard
│   │   ├── dashboard_overview.png
│   │   ├── affinity_matrix_heatmap.png
│   │   └── scatter_confidence_lift.png
│   └── Market_Basket_Dashboard.xlsx    # Standalone Excel workbook
└── README.md
```

## 🚀 Business Applications & Implementation Roadmap

1. **E-Commerce Checkout Add-Ons:** Trigger dynamic "Complete the Look" or "Customers Also Added" carousels based on high-lift rules ($\text{Lift} > 3.0$) when item $A$ is added to cart.
2. **Promotional Bundles & Pricing Strategy:** Bundle high-frequency pairings (`Pathani Kurta + Mojari`) with slight promotional margins to accelerate overall cart size and inventory turnover.
3. **Cross-Department Merchandising:** Reorganize physical retail shelf adjacencies and digital landing pages to place **Fashion & Footwear** alongside complementary **Personal Care** items.

## 👤 Author & Contact

* **Project Owner:** Data Analytics Portfolio
* **Tools Used:** SQL Server (SSMS), Microsoft Excel, Association Rule Mining
