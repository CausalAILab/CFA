
test_that("fairness_cookbook input types", {

  with_seed(201, {
    data <- data_gen(100, add_z = TRUE)
  })
  data$y <- as.integer(data$y) - 1L
  vars <- c("y", "x", "w", "z")

  expect_setequal(colnames(data), vars)

  fc.nms <- c("measures", "x0", "x1", "model", "X", "W", "Z", "Y", "cl",
              "method", "params")

  for (method in c("medDML", "causal_forest")) {

    # apply cookbook to various data types of Y
    ran <- with_seed(
      202,
      fairness_cookbook(data, X = "x", W = "w", Z = "z", Y = "y",
                        x0 = 0, x1 = 1, method = method)
    )

    # both print() and str() throw

    expect_type(ran, "list")
    expect_named(ran, fc.nms, ignore.order = TRUE)

    expect_s3_class(ran, "faircause")
    expect_type(ran[["measures"]], "list")
    expect_identical(ran[["X"]], "x")
    expect_identical(ran[["method"]], method)

    ran.meas <- ran[["measures"]]
    meas.nms <- c("tv", "ctfde", "ctfse", "ett", "ctfie", "te", "nde", "nie",
                  "expse_x1", "expse_x0")
    col.nms <- c("value", "boot", "measure", "rep")
    expect_named(ran.meas, col.nms, ignore.order = TRUE)
    expect_setequal(unique(ran.meas$measure), meas.nms)

    if (method == "causal_forest") {
      expect_true(all(is.na(ran.meas[ran.meas$measure == "expse_x1", ]$value)))
      expect_true(all(is.na(ran.meas[ran.meas$measure == "expse_x0", ]$value)))
    }

  }

})


