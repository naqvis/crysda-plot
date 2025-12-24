require "./spec_helper"

describe "Crysda::DataFrame plotting" do
  describe "#plot_line" do
    it "creates a line plot with single y column" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, 20,
        3, 30,
        4, 40
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "creates a line plot with multiple y columns" do
      df = Crysda.dataframe_of("x", "y1", "y2").values(
        1, 10, 100,
        2, 20, 200,
        3, 30, 300
      )

      plot = df.plot_line("x", "y1", "y2")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles nil values by skipping them" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, nil,
        3, 30
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "works with Float64 columns" do
      df = Crysda.dataframe_of("x", "y").values(
        1.5, 10.5,
        2.5, 20.5,
        3.5, 30.5
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "works with Int64 columns" do
      df = Crysda.dataframe_of("x", "y").values(
        1_i64, 10_i64,
        2_i64, 20_i64,
        3_i64, 30_i64
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "#plot_scatter" do
    it "creates a scatter plot" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, 25,
        3, 15,
        4, 35
      )

      plot = df.plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles nil values" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        nil, 20,
        3, nil,
        4, 40
      )

      plot = df.plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "works with mixed numeric types" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10.5,
        2, 20.5,
        3, 30.5
      )

      plot = df.plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "#plot_bar" do
    it "creates a bar chart with string x-axis" do
      df = Crysda.dataframe_of("category", "value").values(
        "A", 10,
        "B", 20,
        "C", 30
      )

      plot = df.plot_bar("category", "value")
      plot.should be_a(Cryplot::Plot)
    end

    it "creates a bar chart with numeric x-axis" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, 20,
        3, 30
      )

      plot = df.plot_bar("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles nil values in y column" do
      df = Crysda.dataframe_of("category", "value").values(
        "A", 10,
        "B", nil,
        "C", 30
      )

      plot = df.plot_bar("category", "value")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "#plot_histogram" do
    it "creates a histogram with default bins" do
      df = Crysda.dataframe_of("value").values(
        1, 2, 2, 3, 3, 3, 4, 4, 5
      )

      plot = df.plot_histogram("value")
      plot.should be_a(Cryplot::Plot)
    end

    it "creates a histogram with custom bins" do
      df = Crysda.dataframe_of("value").values(
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
      )

      plot = df.plot_histogram("value", bins: 5)
      plot.should be_a(Cryplot::Plot)
    end

    it "handles single value" do
      df = Crysda.dataframe_of("value").values(5, 5, 5, 5)

      plot = df.plot_histogram("value")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles float values" do
      df = Crysda.dataframe_of("value").values(
        1.1, 2.2, 3.3, 4.4, 5.5
      )

      plot = df.plot_histogram("value", bins: 3)
      plot.should be_a(Cryplot::Plot)
    end

    it "skips nil values" do
      df = Crysda.dataframe_of("value").values(
        1, nil, 3, nil, 5
      )

      plot = df.plot_histogram("value")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "#plot_box" do
    it "creates a box plot for single column" do
      df = Crysda.dataframe_of("value").values(
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10
      )

      plot = df.plot_box("value")
      plot.should be_a(Cryplot::Plot)
    end

    it "creates a box plot for multiple columns" do
      df = Crysda.dataframe_of("a", "b", "c").values(
        1, 10, 100,
        2, 20, 200,
        3, 30, 300,
        4, 40, 400,
        5, 50, 500
      )

      plot = df.plot_box("a", "b", "c")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles nil values" do
      df = Crysda.dataframe_of("value").values(
        1, nil, 3, 4, nil, 6, 7, 8, 9, 10
      )

      plot = df.plot_box("value")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "#plot (PlotBuilder)" do
    it "builds a line plot" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, 20,
        3, 30
      )

      plot = df.plot.line("x", "y").build
      plot.should be_a(Cryplot::Plot)
    end

    it "builds a scatter plot" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 10,
        2, 20,
        3, 30
      )

      plot = df.plot.scatter("x", "y").build
      plot.should be_a(Cryplot::Plot)
    end

    it "builds a bar chart" do
      df = Crysda.dataframe_of("cat", "val").values(
        "A", 10,
        "B", 20
      )

      plot = df.plot.bar("cat", "val").build
      plot.should be_a(Cryplot::Plot)
    end

    it "builds a histogram" do
      df = Crysda.dataframe_of("value").values(1, 2, 3, 4, 5)

      plot = df.plot.histogram("value", bins: 3).build
      plot.should be_a(Cryplot::Plot)
    end

    it "allows setting title" do
      df = Crysda.dataframe_of("x", "y").values(1, 10, 2, 20)

      plot = df.plot.line("x", "y").title("My Plot").build
      plot.should be_a(Cryplot::Plot)
    end

    it "allows setting axis labels" do
      df = Crysda.dataframe_of("x", "y").values(1, 10, 2, 20)

      plot = df.plot
        .line("x", "y")
        .xlabel("X Axis")
        .ylabel("Y Axis")
        .build
      plot.should be_a(Cryplot::Plot)
    end

    it "chains multiple configurations" do
      df = Crysda.dataframe_of("x", "y").values(1, 10, 2, 20, 3, 30)

      plot = df.plot
        .scatter("x", "y")
        .title("Scatter Plot")
        .xlabel("Independent Variable")
        .ylabel("Dependent Variable")
        .build

      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "GroupedDataFrame plotting" do
    it "creates scatter plot with groups" do
      df = Crysda.dataframe_of("group", "x", "y").values(
        "A", 1, 10,
        "A", 2, 20,
        "B", 1, 15,
        "B", 2, 25
      )

      plot = df.group_by("group").plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "creates line plot with groups" do
      df = Crysda.dataframe_of("group", "x", "y").values(
        "A", 1, 10,
        "A", 2, 20,
        "A", 3, 30,
        "B", 1, 15,
        "B", 2, 25,
        "B", 3, 35
      )

      plot = df.group_by("group").plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles multiple grouping columns" do
      df = Crysda.dataframe_of("g1", "g2", "x", "y").values(
        "A", "X", 1, 10,
        "A", "X", 2, 20,
        "A", "Y", 1, 15,
        "B", "X", 1, 25
      )

      plot = df.group_by("g1", "g2").plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles empty groups gracefully" do
      df = Crysda.dataframe_of("group", "x", "y").values(
        "A", 1, 10,
        "A", 2, 20
      )

      plot = df.group_by("group").plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "edge cases" do
    it "handles empty dataframe for line plot" do
      df = Crysda.dataframe_of("x", "y").values(
        nil, nil
      )

      # Should not raise, just create empty plot
      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles single row dataframe" do
      df = Crysda.dataframe_of("x", "y").values(1, 10)

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles large dataset" do
      df = Crysda.dataframe_of("x", "y").values(
        1, 2, 2, 4, 3, 6, 4, 8, 5, 10,
        6, 12, 7, 14, 8, 16, 9, 18, 10, 20,
        11, 22, 12, 24, 13, 26, 14, 28, 15, 30,
        16, 32, 17, 34, 18, 36, 19, 38, 20, 40
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles negative values" do
      df = Crysda.dataframe_of("x", "y").values(
        -5, -10,
        0, 0,
        5, 10
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles very small float values" do
      df = Crysda.dataframe_of("x", "y").values(
        0.001, 0.0001,
        0.002, 0.0002,
        0.003, 0.0003
      )

      plot = df.plot_scatter("x", "y")
      plot.should be_a(Cryplot::Plot)
    end

    it "handles very large values" do
      df = Crysda.dataframe_of("x", "y").values(
        1e10, 1e12,
        2e10, 2e12,
        3e10, 3e12
      )

      plot = df.plot_line("x", "y")
      plot.should be_a(Cryplot::Plot)
    end
  end

  describe "return value chaining" do
    it "allows chaining Cryplot methods on plot_line result" do
      df = Crysda.dataframe_of("x", "y").values(1, 10, 2, 20, 3, 30)

      plot = df.plot_line("x", "y")
      plot.xrange(0.0, 4.0)
      plot.yrange(0.0, 40.0)
      plot.should be_a(Cryplot::Plot)
    end

    it "allows chaining Cryplot methods on plot_scatter result" do
      df = Crysda.dataframe_of("x", "y").values(1, 10, 2, 20, 3, 30)

      plot = df.plot_scatter("x", "y")
      plot.title("My Scatter")
      plot.should be_a(Cryplot::Plot)
    end

    it "allows chaining Cryplot methods on plot_bar result" do
      df = Crysda.dataframe_of("cat", "val").values("A", 10, "B", 20)

      plot = df.plot_bar("cat", "val")
      plot.title("Bar Chart")
      plot.should be_a(Cryplot::Plot)
    end

    it "allows chaining Cryplot methods on plot_histogram result" do
      df = Crysda.dataframe_of("value").values(1, 2, 3, 4, 5)

      plot = df.plot_histogram("value")
      plot.title("Histogram")
      plot.should be_a(Cryplot::Plot)
    end
  end
end

describe "PlotConfig" do
  it "has default width and height" do
    Crysda::PlotConfig.default_width.should eq(800)
    Crysda::PlotConfig.default_height.should eq(600)
  end

  it "allows changing default dimensions" do
    original_width = Crysda::PlotConfig.default_width
    original_height = Crysda::PlotConfig.default_height

    Crysda::PlotConfig.default_width = 1024
    Crysda::PlotConfig.default_height = 768

    Crysda::PlotConfig.default_width.should eq(1024)
    Crysda::PlotConfig.default_height.should eq(768)

    # Restore
    Crysda::PlotConfig.default_width = original_width
    Crysda::PlotConfig.default_height = original_height
  end
end

describe "#plot_line with sorted option" do
  it "creates a sorted line plot" do
    df = Crysda.dataframe_of("x", "y").values(
      3, 30,
      1, 10,
      2, 20
    )

    plot = df.plot_line("x", "y", sorted: true)
    plot.should be_a(Cryplot::Plot)
  end

  it "creates unsorted line plot by default" do
    df = Crysda.dataframe_of("x", "y").values(
      3, 30,
      1, 10,
      2, 20
    )

    plot = df.plot_line("x", "y")
    plot.should be_a(Cryplot::Plot)
  end

  it "works with multiple y columns and sorted" do
    df = Crysda.dataframe_of("x", "y1", "y2").values(
      3, 30, 300,
      1, 10, 100,
      2, 20, 200
    )

    plot = df.plot_line("x", "y1", "y2", sorted: true)
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_value_counts" do
  it "creates bar chart from value_counts result" do
    df = Crysda.dataframe_of("category").values(
      "A", "B", "A", "C", "A", "B"
    )

    counts = df.count("category")
    plot = counts.plot_value_counts
    plot.should be_a(Cryplot::Plot)
  end

  it "allows specifying label column" do
    df = Crysda.dataframe_of("cat", "n").values(
      "X", 10,
      "Y", 20,
      "Z", 30
    )

    plot = df.plot_value_counts("cat", "n")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_correlation" do
  it "creates correlation matrix plot" do
    df = Crysda.dataframe_of("a", "b", "c").values(
      1, 2, 3,
      2, 4, 6,
      3, 6, 9,
      4, 8, 12,
      5, 10, 15
    )

    plot = df.plot_correlation
    plot.should be_a(Cryplot::Plot)
  end

  it "handles negative correlations" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 10,
      2, 8,
      3, 6,
      4, 4,
      5, 2
    )

    plot = df.plot_correlation
    plot.should be_a(Cryplot::Plot)
  end

  it "raises error with less than 2 numeric columns" do
    df = Crysda.dataframe_of("x", "name").values(
      1, "a",
      2, "b"
    )

    expect_raises(ArgumentError) do
      df.plot_correlation
    end
  end
end

describe "GroupedDataFrame#plot_line with sorted" do
  it "creates sorted grouped line plot" do
    df = Crysda.dataframe_of("group", "x", "y").values(
      "A", 3, 30,
      "A", 1, 10,
      "A", 2, 20,
      "B", 3, 35,
      "B", 1, 15,
      "B", 2, 25
    )

    plot = df.group_by("group").plot_line("x", "y", sorted: true)
    plot.should be_a(Cryplot::Plot)
  end
end

describe "GroupedDataFrame#plot_facet_scatter" do
  it "creates faceted scatter plots" do
    df = Crysda.dataframe_of("group", "x", "y").values(
      "A", 1, 10,
      "A", 2, 20,
      "B", 1, 15,
      "B", 2, 25,
      "C", 1, 12,
      "C", 2, 22
    )

    fig = df.group_by("group").plot_facet_scatter("x", "y")
    fig.should be_a(Cryplot::Figure)
  end

  it "handles single group" do
    df = Crysda.dataframe_of("group", "x", "y").values(
      "A", 1, 10,
      "A", 2, 20
    )

    fig = df.group_by("group").plot_facet_scatter("x", "y")
    fig.should be_a(Cryplot::Figure)
  end
end

describe "GroupedDataFrame#plot_facet_line" do
  it "creates faceted line plots" do
    df = Crysda.dataframe_of("group", "x", "y").values(
      "A", 1, 10,
      "A", 2, 20,
      "A", 3, 30,
      "B", 1, 15,
      "B", 2, 25,
      "B", 3, 35
    )

    fig = df.group_by("group").plot_facet_line("x", "y")
    fig.should be_a(Cryplot::Figure)
  end

  it "creates sorted faceted line plots" do
    df = Crysda.dataframe_of("group", "x", "y").values(
      "A", 3, 30,
      "A", 1, 10,
      "A", 2, 20,
      "B", 3, 35,
      "B", 1, 15,
      "B", 2, 25
    )

    fig = df.group_by("group").plot_facet_line("x", "y", sorted: true)
    fig.should be_a(Cryplot::Figure)
  end
end

describe "#plot_pairplot" do
  it "creates pairplot for numeric columns" do
    df = Crysda.dataframe_of("a", "b", "c").values(
      1, 2, 3,
      2, 4, 5,
      3, 6, 7,
      4, 8, 9,
      5, 10, 11
    )

    fig = df.plot_pairplot
    fig.should be_a(Cryplot::Figure)
  end

  it "raises error with less than 2 numeric columns" do
    df = Crysda.dataframe_of("x", "name").values(
      1, "a",
      2, "b"
    )

    expect_raises(ArgumentError) do
      df.plot_pairplot
    end
  end
end

describe "#plot_regression" do
  it "creates scatter plot with regression line" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 2,
      2, 4,
      3, 5,
      4, 8,
      5, 10
    )

    plot = df.plot_regression("x", "y")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles perfect correlation" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 2,
      2, 4,
      3, 6,
      4, 8
    )

    plot = df.plot_regression("x", "y")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles negative correlation" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 10,
      2, 8,
      3, 6,
      4, 4,
      5, 2
    )

    plot = df.plot_regression("x", "y")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles single data point gracefully" do
    df = Crysda.dataframe_of("x", "y").values(1, 10)

    plot = df.plot_regression("x", "y")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_stacked_bar" do
  it "creates stacked bar chart" do
    df = Crysda.dataframe_of("category", "a", "b", "c").values(
      "X", 10, 20, 30,
      "Y", 15, 25, 35,
      "Z", 20, 30, 40
    )

    plot = df.plot_stacked_bar("category", "a", "b", "c")
    plot.should be_a(Cryplot::Plot)
  end

  it "works with two columns" do
    df = Crysda.dataframe_of("cat", "v1", "v2").values(
      "A", 10, 20,
      "B", 15, 25
    )

    plot = df.plot_stacked_bar("cat", "v1", "v2")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_grouped_bar" do
  it "creates grouped bar chart" do
    df = Crysda.dataframe_of("category", "a", "b", "c").values(
      "X", 10, 20, 30,
      "Y", 15, 25, 35,
      "Z", 20, 30, 40
    )

    plot = df.plot_grouped_bar("category", "a", "b", "c")
    plot.should be_a(Cryplot::Plot)
  end

  it "works with two columns" do
    df = Crysda.dataframe_of("cat", "v1", "v2").values(
      "A", 10, 20,
      "B", 15, 25
    )

    plot = df.plot_grouped_bar("cat", "v1", "v2")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_heatmap" do
  it "creates heatmap from three columns" do
    df = Crysda.dataframe_of("x", "y", "value").values(
      "A", "X", 10,
      "A", "Y", 20,
      "B", "X", 30,
      "B", "Y", 40
    )

    plot = df.plot_heatmap("x", "y", "value")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles numeric categories" do
    df = Crysda.dataframe_of("row", "col", "val").values(
      1, 1, 10,
      1, 2, 20,
      2, 1, 30,
      2, 2, 40
    )

    plot = df.plot_heatmap("col", "row", "val")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_distribution" do
  it "creates distribution plot with histogram and KDE" do
    df = Crysda.dataframe_of("value").values(
      1, 2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 8, 9, 10
    )

    plot = df.plot_distribution("value")
    plot.should be_a(Cryplot::Plot)
  end

  it "creates distribution plot without KDE" do
    df = Crysda.dataframe_of("value").values(
      1, 2, 3, 4, 5
    )

    plot = df.plot_distribution("value", kde: false)
    plot.should be_a(Cryplot::Plot)
  end

  it "allows custom bin count" do
    df = Crysda.dataframe_of("value").values(
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    )

    plot = df.plot_distribution("value", bins: 5)
    plot.should be_a(Cryplot::Plot)
  end

  it "handles float values" do
    df = Crysda.dataframe_of("value").values(
      1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9
    )

    plot = df.plot_distribution("value")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles empty data" do
    df = Crysda.dataframe_of("value").values(nil, nil)

    plot = df.plot_distribution("value")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_area" do
  it "creates stacked area chart" do
    df = Crysda.dataframe_of("x", "a", "b", "c").values(
      1, 10, 20, 30,
      2, 15, 25, 35,
      3, 20, 30, 40
    )

    plot = df.plot_area("x", "a", "b", "c")
    plot.should be_a(Cryplot::Plot)
  end

  it "works with two series" do
    df = Crysda.dataframe_of("x", "y1", "y2").values(
      1, 10, 20,
      2, 15, 25
    )

    plot = df.plot_area("x", "y1", "y2")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_errorbar" do
  it "creates scatter plot with error bars" do
    df = Crysda.dataframe_of("x", "y", "err").values(
      1, 10, 2,
      2, 20, 3,
      3, 30, 4
    )

    plot = df.plot_errorbar("x", "y", "err")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_stem" do
  it "creates stem/lollipop chart" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 10,
      2, 25,
      3, 15,
      4, 30
    )

    plot = df.plot_stem("x", "y")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_pie" do
  it "creates pie chart" do
    df = Crysda.dataframe_of("category", "value").values(
      "A", 30,
      "B", 50,
      "C", 20
    )

    plot = df.plot_pie("category", "value")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles many slices" do
    df = Crysda.dataframe_of("cat", "val").values(
      "A", 10,
      "B", 20,
      "C", 30,
      "D", 15,
      "E", 25
    )

    plot = df.plot_pie("cat", "val")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_hexbin" do
  it "creates hexbin density plot" do
    df = Crysda.dataframe_of("x", "y").values(
      1, 1, 1.1, 1.1, 2, 2, 2.1, 2.1,
      3, 3, 3.1, 3.1, 4, 4, 4.1, 4.1
    )

    plot = df.plot_hexbin("x", "y", bins: 5)
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_qq" do
  it "creates Q-Q plot" do
    df = Crysda.dataframe_of("value").values(
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    )

    plot = df.plot_qq("value")
    plot.should be_a(Cryplot::Plot)
  end

  it "handles small dataset" do
    df = Crysda.dataframe_of("value").values(1, 2, 3)

    plot = df.plot_qq("value")
    plot.should be_a(Cryplot::Plot)
  end
end

describe "#plot_density" do
  it "creates density plot for single column" do
    df = Crysda.dataframe_of("value").values(
      1, 2, 2, 3, 3, 3, 4, 4, 5
    )

    plot = df.plot_density("value")
    plot.should be_a(Cryplot::Plot)
  end

  it "creates density plot for multiple columns" do
    df = Crysda.dataframe_of("a", "b").values(
      1, 10,
      2, 20,
      3, 30,
      4, 40,
      5, 50
    )

    plot = df.plot_density("a", "b")
    plot.should be_a(Cryplot::Plot)
  end
end
