defmodule SpeedQuiz do
  # Numbers to be added will fall in this range
  @range 1..10

  # Ask this many questions
  @question_count 5

  def run do
    questions = generate_questions(@range)
    start_time = DateTime.utc_now()

    run_round(questions, start_time)
  end

  defp generate_questions(num_range) do
    for i1 <- num_range, i2 <- num_range do
      [i1, i2]
    end
    |> Enum.shuffle()
    |> Enum.take(@question_count)
  end

  defp run_round([[i1, i2] | rest] = all, start_time) do
    response = IO.gets("What's #{i1} + #{i2}?\n")

    with {:ok, answer} <- parse_to_num(response),
         true <- answer == i1 + i2 do
      IO.puts("Yay!\n")
      run_round(rest, start_time)
    else
      _ ->
        IO.puts("Sorry, nope.\n")
        run_round(Enum.shuffle(all), start_time)
    end
  end

  defp run_round([], start_time) do
    elapsed = DateTime.diff(DateTime.utc_now(), start_time, :second)
    average = Float.round(elapsed / @question_count, 3)

    unit = if average == 1, do: "second", else: "seconds"

    clip_task = play_random_victory_clip()
    victory_message = random_victory_message()

    IO.puts("""
    #{victory_message}
    It took you #{elapsed} seconds to answer #{@question_count} questions - an average of #{average} #{unit} per question.
    """)

    Task.await(clip_task)
  end

  defp parse_to_num(str) do
    str = String.trim(str)

    case Integer.parse(str) do
      {i, ""} -> {:ok, i}
      _ -> :error
    end
  end

  defp random_victory_message do
    "victory_messages.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.random()
  end

  defp play_random_victory_clip do
    filename =
      "victory_clips"
      |> File.ls!()
      |> Enum.random()

    Task.async(fn ->
      System.cmd("afplay", ["victory_clips/#{filename}"])
    end)
  end
end

SpeedQuiz.run()
