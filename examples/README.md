# Examples

Run any example with:

```bash
crystal run examples/<example_name>.cr
```

## Iris Dataset Examples

| Example                                                | Chart Type         | Description                            |
| ------------------------------------------------------ | ------------------ | -------------------------------------- |
| [iris_species_analysis.cr](iris_species_analysis.cr)   | Grouped Scatter    | Species clustering by petal dimensions |
| [iris_measurements_line.cr](iris_measurements_line.cr) | Multi-Series Line  | Comparing measurements across species  |
| [iris_correlation.cr](iris_correlation.cr)             | Correlation Matrix | Numeric column correlations            |
| [iris_facets.cr](iris_facets.cr)                       | Faceted Scatter    | Small multiples by species             |
| [iris_pairplot.cr](iris_pairplot.cr)                   | Pairplot           | Scatter matrix of all features         |
| [iris_regression.cr](iris_regression.cr)               | Regression         | Linear fit with R² annotation          |
| [iris_qq.cr](iris_qq.cr)                               | Q-Q Plot           | Normality check for Sepal.Length       |
| [iris_density.cr](iris_density.cr)                     | Density            | KDE curves for all features            |
| [iris_stem.cr](iris_stem.cr)                           | Stem/Lollipop      | Discrete value visualization           |

## Sleep Dataset Examples

| Example                                        | Chart Type   | Description                 |
| ---------------------------------------------- | ------------ | --------------------------- |
| [sleep_analysis.cr](sleep_analysis.cr)         | Bar Chart    | Average sleep by diet type  |
| [sleep_histogram.cr](sleep_histogram.cr)       | Histogram    | Sleep duration distribution |
| [sleep_distribution.cr](sleep_distribution.cr) | Distribution | Histogram with KDE overlay  |
| [sleep_boxplot.cr](sleep_boxplot.cr)           | Box Plot     | Comparing sleep metrics     |
| [sleep_grouped_bar.cr](sleep_grouped_bar.cr)   | Grouped Bar  | Sleep vs awake by diet type |
| [sleep_pie.cr](sleep_pie.cr)                   | Pie Chart    | Mammals by diet type        |
| [sleep_area.cr](sleep_area.cr)                 | Area Chart   | Stacked composition         |

## Data Files

- `data/iris.txt` - Classic iris flower dataset (tab-separated)
- `data/msleep.csv` - Mammal sleep patterns dataset
