get_story <- function(prompt, 
                      num_of_sentences = 5,
                      max_tokens = 1000,
                      ACCOUNT_ID = Sys.getenv("ACCOUNT_ID"), 
                      API_KEY = Sys.getenv("API_KEY"),
                      base_url = cf_base_url()){
  
  url_txt <- paste0(base_url, ACCOUNT_ID, "/ai/run/@cf/meta/llama-3.1-8b-instruct")
  
  # Make an API request
  response_text <- httr2::request(url_txt) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", API_KEY)
    ) |>
    httr2::req_body_json(list(
      max_tokens = max_tokens,
      messages = list(
        list(role = "system", 
             content = paste0("You tell short stories. 
             Each sentence must describe all details. 
             Each story must have ",  num_of_sentences,  " sentences. 
             The story must have a beginning, a climax and an end.")), 
        list(
          role = "user", 
          content = prompt
        )
      ))) |>
    httr2::req_method("POST") |>
    httr2::req_perform() |> 
    httr2::resp_body_json()
  
  # If response is successful, append it to the user prompt
  # clean it, and split the text into 5 sentences
  if (isTRUE(response_text$success)){
    full_text <- response_text$result$response #paste(prompt, response_text$result$response) 
    cleaned_text <- gsub("\n", "", full_text)
    split_text <- unlist(strsplit(cleaned_text, "(?<=[.])\\s*(?=[A-Z])", perl = TRUE))
  } else {
    split_text <- NULL
  }
  
  # c(prompt, split_text)
  split_text
}
