library(shiny)
library(DT)

function(input, output, session) {
  per_pizza_weight <- reactive({
    if (isTRUE(input$size_mode == "diameter")) {
      req(input$pizza_diameter, input$g_per_sq_in)
      pi * (input$pizza_diameter / 2)^2 * input$g_per_sq_in
    } else {
      req(input$ball_weight)
      input$ball_weight
    }
  })

  # Reactive for total target weight
  total_target_weight <- reactive({
    req(input$num_balls, per_pizza_weight())
    input$num_balls * per_pizza_weight()
  })

  # Reactive for Baker's Math total percentage
  total_bakers_pct <- reactive({
    100 +
      input$hydration +
      input$salt_pct +
      input$yeast_pct +
      input$oil_pct +
      input$sugar_pct
  })

  # Calculate the recipe
  recipe_data <- reactive({
    total_weight <- total_target_weight()
    total_pct <- total_bakers_pct()

    # The core baker's math formula: Flour = Total Weight / (Total Baker's % / 100)
    flour_g <- total_weight / (total_pct / 100)

    # Calculate other ingredients based on the flour weight
    water_g <- flour_g * (input$hydration / 100)
    salt_g <- flour_g * (input$salt_pct / 100)
    yeast_g <- flour_g * (input$yeast_pct / 100)
    oil_g <- flour_g * (input$oil_pct / 100)
    sugar_g <- flour_g * (input$sugar_pct / 100)

    # Create data frame
    df <- data.frame(
      Ingredient = c(
        "Flour (100%)",
        "Water",
        "Salt",
        "Yeast",
        "Oil/Fat",
        "Sugar/Honey"
      ),
      Grams = c(flour_g, water_g, salt_g, yeast_g, oil_g, sugar_g),
      Bakers_Percent = c(
        100,
        input$hydration,
        input$salt_pct,
        input$yeast_pct,
        input$oil_pct,
        input$sugar_pct
      )
    )

    # Filter out zero-amount optional ingredients for cleaner table
    df <- df[df$Grams > 0, ]

    df
  })

  flour_weight <- reactive({
    dat <- recipe_data()
    flour_row <- dat$Grams[dat$Ingredient == "Flour (100%)"]
    if (length(flour_row) == 0) {
      return(NA_real_)
    }
    flour_row[[1]]
  })

  # --- Outputs ---

  output$recipe_title <- renderText({
    if (isTRUE(input$size_mode == "diameter")) {
      paste(
        "Recipe for",
        input$num_balls,
        "pizza(s) at",
        round(input$pizza_diameter),
        "in each (~",
        round(per_pizza_weight()),
        "g each)"
      )
    } else {
      paste(
        "Recipe for",
        input$num_balls,
        "pizza(s) at",
        input$ball_weight,
        "g each"
      )
    }
  })

  output$recipe_table <- renderDT({
    dat <- recipe_data()

    datatable(
      dat,
      options = list(
        dom = "t",
        paging = FALSE,
        ordering = FALSE,
        info = FALSE,
        autoWidth = TRUE,
        scrollX = TRUE
      ),
      rownames = FALSE,
      colnames = c("Ingredient", "Weight (g)", "Baker's %")
    ) %>%
      formatRound(columns = c("Grams", "Bakers_Percent"), digits = 0) %>%
      formatString(columns = c("Bakers_Percent"), suffix = "%")
  })

  output$total_dough_weight <- renderText({
    if (isTRUE(input$size_mode == "diameter")) {
      paste0(
        "Total Dough Weight: ",
        format(round(total_target_weight()), big.mark = ","),
        "g (",
        round(per_pizza_weight()),
        "g per ",
        round(input$pizza_diameter),
        " in pizza)"
      )
    } else {
      paste0(
        "Total Dough Weight: ",
        format(round(total_target_weight()), big.mark = ","),
        "g"
      )
    }
  })

  output$hydration_summary <- renderText({
    paste0(
      "Hydration Level: ",
      input$hydration,
      "% (",
      ifelse(
        input$hydration < 60,
        "Stiff dough, good for standard ovens",
        ifelse(
          input$hydration > 70,
          "Wet dough, requires high heat/skill",
          "Standard workable dough"
        )
      ),
      ")"
    )
  })

  output$per_ball_summary <- renderText({
    paste0(round(per_pizza_weight()), " g each")
  })

  output$flour_summary <- renderText({
    paste0(round(flour_weight(), 0), " g flour")
  })

  output$formula_summary <- renderText({
    paste0(
      round(total_bakers_pct()),
      "% total formula"
    )
  })

  # Reset button observer
  observeEvent(input$reset, {
    updateRadioButtons(session, "size_mode", selected = "weight")
    updateNumericInput(session, "num_balls", value = 4)
    updateNumericInput(session, "ball_weight", value = 250)
    updateNumericInput(session, "pizza_diameter", value = 12)
    updateNumericInput(session, "g_per_sq_in", value = 2.2)
    updateSliderInput(session, "hydration", value = 65)
    updateNumericInput(session, "salt_pct", value = 2.0)
    updateNumericInput(session, "yeast_pct", value = 0.6)
    updateNumericInput(session, "oil_pct", value = 0)
    updateNumericInput(session, "sugar_pct", value = 0)
  })
}
