defmodule Mud.Engine.Command.Say do
  @moduledoc """
  The SAY command allows the Character to speak to one or more other Characters in an area. The speech is always 'public' even when directed to a single Character.

  SAY, ", and ' are all interchangable and will trigger the SAY command. In the case of the latter two, no space is required between the punctuation and the rest of the command as might usually be required. See Examples below.

  Either 'to' or '@' may be used to direct the speech to a single Character, but both may not be used at the same time. In the case where '@' is used there should not be a space between the symbol and the character name. See Examples below.

  Emotes are preceeded, without a space, by the forward slash '/' character. If a default emote has been set it will be used in any case where no emote has been specified.

  Examples:
    - say Hello World!
    - 'Hello World!
    - 'Hello World!
    - say to world Hello World!
    - '@world Hello World!
    - say /slowly @world Goobye, cruel world!
    - '@george /quick Do you feel lucky?
    - '/angry Why me?

  For a list of emotes:
    - say /emotes

  To set a default emote:
    - '/emotes <default>
  """

  alias Mud.Engine.Search
  alias Mud.Engine.Message
  alias Mud.Engine.Command.Context
  alias Mud.Engine.{Character}
  alias Mud.Engine.Util
  alias Mud.Engine.Character.Settings

  require Logger

  use Mud.Engine.Command.Callback

  # The process which executes the command logic first calls this method to have it parse the raw command AST nodes
  # into something that the actual command execution logic expects and can more easily use.

  # In some cases this may not even really be necessary, or at least it can act as simply a passthrough and :ok
  # can be returned.
  def build_ast(ast_nodes) do
    IO.inspect(ast_nodes,
      label: :build_ast
    )

    %{
      character:
        Enum.find(ast_nodes, %{input: nil}, fn node ->
          node.key in [:at_character, :to_character]
        end)
        |> Map.get(:input),
      switch:
        Enum.find(ast_nodes, %{input: nil}, fn node -> node.key in [:switch] end)
        |> Map.get(:input),
      words:
        Enum.find(ast_nodes, %{input: nil}, fn node -> node.key in [:words] end)
        |> Map.get(:input)
    }
  end

  # This is where the actual execution of the command takes place.
  # At this point the execution context (found at: lib/mud/engine/command/execution_context.ex) is populated and the
  # build_ast function above has been called.
  @impl true
  def execute(context) do
    Logger.debug("Executing Say command")
    Logger.debug(inspect(context))
    # Extract the ast for ease of access
    ast = context.command.ast

    IO.inspect(ast,
      label: :execute
    )

    case ast do
      %{character: nil, switch: nil, words: nil} ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            Util.get_module_docs(__MODULE__),
            "system_info"
          )
        )

      %{switch: "emotes", words: nil} ->
        list_emotes(context)

      %{switch: "emotes", words: "reset"} ->
        clear_default_emote(context)

      %{switch: "emotes"} ->
        set_default_emote(context)

      %{character: nil} ->
        validate_switch(context, ast)

      _ ->
        find_character_for_say(context)
    end
  end

  defp clear_default_emote(context) do
    Settings.update!(context.character.settings, %{
      commands:
        Map.from_struct(%{
          context.character.settings.commands
          | say_default_emote: nil
        })
    })

    Context.append_message(
      context,
      Message.new_story_output(
        context.character.id,
        "Cleared default emote for the SAY command.",
        "system_info"
      )
    )
  end

  defp set_default_emote(context) do
    ast = context.command.ast

    IO.inspect(ast.words,
      label: :set_default_emote
    )

    IO.inspect(context.character.settings.commands.say_requires_exact_emote,
      label: :set_default_emote
    )

    result =
      normalize_switch(ast.words, context.character.settings.commands.say_requires_exact_emote)

    case result do
      {:ok, normalized_switch} ->
        Settings.update!(context.character.settings, %{
          commands:
            Map.from_struct(%{
              context.character.settings.commands
              | say_default_emote: normalized_switch
            })
        })

        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "Saved the following emote as the default for the SAY command: #{normalized_switch}",
            "system_info"
          )
        )

      {:error, _} ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "Emote not recognized. No default set.",
            "system_alert"
          )
        )
    end
  end

  defp find_character_for_say(context) do
    ast = context.command.ast

    results = Search.search_characters_in_area(context.character.area_id, ast.character)

    case results do
      {:ok, [match]} ->
        ast = %{ast | character: match.match.name}

        validate_switch(context, ast)

      {:error, _} ->
        Context.append_message(
          context,
          Message.new_story_output(
            context.character.id,
            "Who did you wish to speak to?",
            "system_warning"
          )
        )
    end
  end

  defp validate_switch(context, ast = %{switch: nil}) do
    IO.inspect(context.character.settings.commands.say_default_emote, label: :validate_switch)
    # If there is a default emote while none has been provided by the player, use the default
    if not is_nil(context.character.settings.commands.say_default_emote) do
      say_thing(context, %{ast | switch: context.character.settings.commands.say_default_emote})
    else
      # No emote has been provided by the player but there is no default emote saved in the character either, just continue
      say_thing(context, ast)
    end
  end

  defp validate_switch(context, ast = %{switch: switch}) do
    result =
      normalize_switch(switch, context.character.settings.commands.say_requires_exact_emote)

    case result do
      {:ok, normalized_switch} ->
        ast = %{ast | switch: normalized_switch}

        say_thing(context, ast)

      {:error, _} ->
        context =
          Context.append_message(
            context,
            Message.new_story_output(
              context.character.id,
              "Emote not recognized and is being ignored. See SAY commnad for information on available emotes.",
              "system_warning"
            )
          )

        ast = %{ast | switch: nil}
        say_thing(context, ast)
    end
  end

  defp say_thing(context, ast) do
    all_characters =
      Character.list_others_active_in_areas(
        context.character.id,
        context.character.area_id
      )

    # If there is a character being spoken to we want to remove it from the list of characters to which the normal speaking message goes to

    others = Enum.filter(all_characters, &(&1.name !== ast.character))

    words = Util.upcase_first(ast.words)

    {self, other} =
      cond do
        String.ends_with?(ast.words, "!") ->
          {"exclaim", "exclaims"}

        String.ends_with?(ast.words, "?") ->
          {"ask", "asks"}

        true ->
          {"say", "says"}
      end

    other_msg =
      others
      |> Message.new_story_output()
      |> Message.append_text("#{context.character.name}", "character")
      |> maybe_add_switch(ast)
      |> Message.append_text(" #{other}", "base")
      |> maybe_add_character(ast)
      |> Message.append_text(", \"#{words}\"", "base")

    self_msg =
      context.character.id
      |> Message.new_story_output()
      |> Message.append_text("You", "character")
      |> maybe_add_switch(ast)
      |> Message.append_text(" #{self}", "base")
      |> maybe_add_character(ast)
      |> Message.append_text(", \"#{words}\"", "base")

    context =
      context
      |> Context.append_message(other_msg)
      |> Context.append_message(self_msg)

    if not is_nil(ast.character) do
      target =
        Enum.fetch!(all_characters, Enum.find_index(all_characters, &(&1.name == ast.character)))

      target_msg =
        target.id
        |> Message.new_story_output()
        |> Message.append_text("#{context.character.name}", "character")
        |> maybe_add_switch(ast)
        |> Message.append_text(" #{other}", "base")
        |> maybe_add_character(ast, true)
        |> Message.append_text(", \"#{words}\"", "base")

      Context.append_message(context, target_msg)
    else
      context
    end
  end

  defp maybe_add_character(message, ast, is_target \\ false)

  defp maybe_add_character(message, %{character: nil}, _is_target) do
    message
  end

  defp maybe_add_character(message, %{character: character}, false) do
    message
    |> Message.append_text(" to ", "base")
    |> Message.append_text("#{character}", "character")
  end

  defp maybe_add_character(message, %{character: _character}, true) do
    message
    |> Message.append_text(" to ", "base")
    |> Message.append_text("you", "character")
  end

  defp maybe_add_switch(message, %{switch: nil}) do
    message
  end

  defp maybe_add_switch(message, %{switch: switch}) do
    Message.append_text(message, " #{switch}", "base")
  end

  @possible_emotes [
    "absentmindedly",
    "acerbically",
    "acidly",
    "adamantly",
    "admiringly",
    "adoringly",
    "affably",
    "affectionately",
    "aggressively",
    "agreeably",
    "ambiguously",
    "ambivalently",
    "angrily",
    "animatedly",
    "anxiously",
    "apathetically",
    "apologetically",
    "apoplectically",
    "appreciatively",
    "apprehensively",
    "approvingly",
    "ardently",
    "arrogantly",
    "articulately",
    "artlessly",
    "assertively",
    "attentively",
    "audaciously",
    "awkwardly",
    "bashfully",
    "begrudgingly",
    "beguilingly",
    "belligerently",
    "benignly",
    "bewilderedly",
    "bitingly",
    "bitterly",
    "bizarrely",
    "blandly",
    "bleakly",
    "blissfully",
    "blithely",
    "bluntly",
    "boastfully",
    "boisterously",
    "boldly",
    "boorishly",
    "brashly",
    "bravely",
    "brazenly",
    "brightly",
    "briskly",
    "brusquely",
    "brutally",
    "busily",
    "callously",
    "calmly",
    "candidly",
    "cantankerously",
    "carefully",
    "carelessly",
    "casually",
    "cattily",
    "cautiously",
    "ceremoniously",
    "charmingly",
    "cheekily",
    "cheerfully",
    "cheerlessly",
    "chivalrously",
    "circumspectly",
    "clearly",
    "clumsily",
    "coarsely",
    "coaxingly",
    "coldly",
    "compassionately",
    "concisely",
    "condescendingly",
    "confidently",
    "conscientiously",
    "considerately",
    "consolingly",
    "contemptuously",
    "contentedly",
    "contritely",
    "coolly",
    "cooperatively",
    "courageously",
    "courteously",
    "covetously",
    "coyly",
    "crassly",
    "credulously",
    "crisply",
    "critically",
    "crossly",
    "crudely",
    "cruelly",
    "cunningly",
    "curiously",
    "curtly",
    "cynically",
    "dangerously",
    "daringly",
    "darkly",
    "dauntlessly",
    "dazedly",
    "decently",
    "deceptively",
    "decisively",
    "deeply",
    "deferentially",
    "defiantly",
    "dejectedly",
    "deliberately",
    "delicately",
    "delightedly",
    "densely",
    "depressingly",
    "derisively",
    "desperately",
    "despondently",
    "deviously",
    "devotedly",
    "devoutly",
    "diffidently",
    "diplomatically",
    "directly",
    "disagreeably",
    "discerningly",
    "discreetly",
    "disdainfully",
    "disgustedly",
    "disingenuously",
    "dismally",
    "dispassionately",
    "disrespectfully",
    "distantly",
    "distractedly",
    "divisively",
    "docilely",
    "dolefully",
    "dopily",
    "dotingly",
    "doubtfully",
    "dramatically",
    "dreamily",
    "drowsily",
    "drunkenly",
    "dryly",
    "dully",
    "duplicitously",
    "dutifully",
    "eagerly",
    "earnestly",
    "ecstatically",
    "eerily",
    "eloquently",
    "emotionlessly",
    "emphatically",
    "endearingly",
    "energetically",
    "enigmatically",
    "enthusiastically",
    "enviously",
    "ethically",
    "euphorically",
    "evasively",
    "excitedly",
    "explicitly",
    "exultantly",
    "faintly",
    "fairly",
    "faithfully",
    "faithlessly",
    "falsely",
    "fatally",
    "fearfully",
    "fearlessly",
    "feebly",
    "ferociously",
    "fervently",
    "fiercely",
    "firmly",
    "flamboyantly",
    "flatly",
    "fluently",
    "fluidly",
    "fondly",
    "foolishly",
    "formally",
    "frankly",
    "frantically",
    "frenetically",
    "fretfully",
    "furiously",
    "futilely",
    "generously",
    "gently",
    "genuinely",
    "gingerly",
    "gleefully",
    "gloomily",
    "graciously",
    "gratefully",
    "gravely",
    "greedily",
    "grievously",
    "groggily",
    "gruesomely",
    "gruffly",
    "grumblingly",
    "grumpily",
    "guardedly",
    "gullibly",
    "haggardly",
    "haltingly",
    "happily",
    "harshly",
    "hastily",
    "hatefully",
    "haughtily",
    "hauntingly",
    "heartily",
    "heavily",
    "helplessly",
    "hesitantly",
    "hoarsely",
    "hollowly",
    "honestly",
    "hopefully",
    "hopelessly",
    "humbly",
    "humorously",
    "hungrily",
    "hurriedly",
    "hypocritically",
    "hysterically",
    "idiotically",
    "ignorantly",
    "imaginatively",
    "impartially",
    "impassively",
    "impatiently",
    "imperiously",
    "impertinently",
    "impiously",
    "impishly",
    "impudently",
    "impulsively",
    "incoherently",
    "inconsiderately",
    "incredulously",
    "indecisively",
    "indifferently",
    "indignantly",
    "inflexibly",
    "informally",
    "innocently",
    "inquiringly",
    "inquisitively",
    "insanely",
    "insincerely",
    "insinuatingly",
    "insolently",
    "inspiringly",
    "intelligently",
    "intensely",
    "intently",
    "irately",
    "ironically",
    "irreverently",
    "irritably",
    "jauntily",
    "jealously",
    "jokingly",
    "joshingly",
    "jovially",
    "joyfully",
    "joylessly",
    "jubilantly",
    "judgmentally",
    "judiciously",
    "justly",
    "kindheartedly",
    "kindly",
    "knavishly",
    "knowingly",
    "kookily",
    "lackadaisically",
    "laconically",
    "languidly",
    "laughingly",
    "lazily",
    "lethargically",
    "lightheartedly",
    "lightly",
    "limply",
    "lispingly",
    "loathingly",
    "loftily",
    "longingly",
    "loudly",
    "lovingly",
    "loyally",
    "ludicrously",
    "lyrically",
    "madly",
    "malevolently",
    "malignantly",
    "maniacally",
    "manically",
    "matter-of-factly",
    "mawkishly",
    "meaningfully",
    "mechanically",
    "meekly",
    "melodically",
    "melodiously",
    "mendaciously",
    "merrily",
    "methodically",
    "mildly",
    "mindfully",
    "mirthfully",
    "mischievously",
    "miserably",
    "mistakenly",
    "mockingly",
    "modestly",
    "morbidly",
    "moronically",
    "morosely",
    "mournfully",
    "mulishly",
    "mysteriously",
    "naively",
    "nasally",
    "naughtily",
    "nervously",
    "neurotically",
    "noisily",
    "numbly",
    "obediently",
    "obligingly",
    "obnoxiously",
    "observantly",
    "obstinately",
    "obstreperously",
    "obtusely",
    "oddly",
    "offensively",
    "ominously",
    "openly",
    "operatically",
    "optimistically",
    "outrageously",
    "overjoyously",
    "overconfidently",
    "painfully",
    "passionately",
    "passively",
    "patiently",
    "patronizingly",
    "peevishly",
    "penitently",
    "pensively",
    "pessimistically",
    "phonily",
    "piously",
    "pithily",
    "pitifully",
    "pityingly",
    "placidly",
    "playfully",
    "pleasantly",
    "poetically",
    "pointedly",
    "politely",
    "pompously",
    "ponderously",
    "positively",
    "powerfully",
    "prayerfully",
    "precisely",
    "pretentiously",
    "primly",
    "profoundly",
    "proudly",
    "pugnaciously",
    "quarrelsomely",
    "quaveringly",
    "queasily",
    "querulously",
    "questioningly",
    "quickly",
    "quietly",
    "quizzically",
    "rancidly",
    "rancorously",
    "randily",
    "rapaciously",
    "rapidly",
    "rapturously",
    "rashly",
    "raucously",
    "ravenously",
    "reassuringly",
    "recklessly",
    "regretfully",
    "reluctantly",
    "remorsefully",
    "reproachfully",
    "resentfully",
    "resignedly",
    "resonantly",
    "respectfully",
    "restlessly",
    "reverentially",
    "reverently",
    "rhetorically",
    "rhythmically",
    "righteously",
    "rightly",
    "rigidly",
    "roughly",
    "rudely",
    "ruefully",
    "ruthlessly",
    "sadly",
    "saltily",
    "sanctimoniously",
    "sarcastically",
    "sardonically",
    "sassily",
    "savagely",
    "savvily",
    "scornfully",
    "searchingly",
    "sedately",
    "sensibly",
    "sentamentally",
    "serenely",
    "seriously",
    "severely",
    "shakily",
    "shamefully",
    "sharply",
    "sheepishly",
    "shrewdly",
    "shriekingly",
    "shrilly",
    "shyly",
    "sibilantly",
    "simperingly",
    "simply",
    "sincerely",
    "skeptically",
    "sleepily",
    "slickly",
    "slothfully",
    "slowly",
    "slyly",
    "smartly",
    "smoothly",
    "smugly",
    "snarkily",
    "snidely",
    "soberly",
    "softly",
    "solemnly",
    "solicitously",
    "somberly",
    "sonorously",
    "soothingly",
    "sorrowfully",
    "spasmodically",
    "spitefully",
    "spontaneously",
    "squeakily",
    "sternly",
    "stiffly",
    "stoically",
    "stormily",
    "strangely",
    "strictly",
    "strongly",
    "stubbornly",
    "stupidly",
    "stutteringly",
    "suavely",
    "subconsciously",
    "succinctly",
    "suspiciously",
    "sweetly",
    "sympathetically",
    "tactfully",
    "tactlessly",
    "tearfully",
    "teasingly",
    "tempestuously",
    "tenderly",
    "tensely",
    "tepidly",
    "tersely",
    "thankfully",
    "thanklessly",
    "theatrically",
    "thoughtfully",
    "thoughtlessly",
    "threateningly",
    "timidly",
    "timorously",
    "tiredly",
    "tonelessly",
    "tranquilly",
    "tremulously",
    "triumphantly",
    "truthfully",
    "tumultuously",
    "unabashedly",
    "unambiguously",
    "unappreciatively",
    "unceremoniously",
    "uncomfortably",
    "unconvincingly",
    "uncooperatively",
    "uncouthly",
    "undiscerningly",
    "uneasily",
    "unemotionally",
    "unethically",
    "unflinchingly",
    "ungratefully",
    "unhappily",
    "unimaginatively",
    "uninterestedly",
    "unnaturally",
    "untruthfully",
    "upliftingly",
    "urgently",
    "uselessly",
    "vacantly",
    "vaguely",
    "vainly",
    "valiantly",
    "valorously",
    "vehemently",
    "vengefully",
    "venomously",
    "viciously",
    "victoriously",
    "vindictively",
    "virtuously",
    "vivaciously",
    "voraciously",
    "warily",
    "warmly",
    "warningly",
    "weakly",
    "wearily",
    "weirdly",
    "wheezily",
    "whiningly",
    "wickedly",
    "wildly",
    "willfully",
    "wisely",
    "wistfully",
    "witheringly",
    "wittily",
    "woefully",
    "wonderingly",
    "woodenly",
    "worriedly",
    "worshipfully",
    "wryly",
    "yearningly",
    "yieldingly",
    "zanily",
    "zealously",
    "zestfully"
  ]

  defp normalize_switch(switch, say_requires_exact_emote) do
    result =
      Enum.find(@possible_emotes, nil, fn emote ->
        if say_requires_exact_emote do
          emote === switch
        else
          String.starts_with?(emote, switch)
        end
      end)

    if not is_nil(result) do
      {:ok, result}
    else
      {:error, :not_found}
    end
  end

  defp list_emotes(context) do
    chunked_emotes = Enum.chunk_every(@possible_emotes, 4, 4, ["", "", "", ""])

    title = "Available Emotes"

    formatted_table_output =
      TableRex.Table.new(chunked_emotes)
      |> TableRex.Table.put_column_meta(:all, align: :center)
      |> TableRex.Table.put_title(title)
      |> TableRex.Table.render!(horizontal_style: :all)

    Context.append_message(
      context,
      Message.new_story_output(
        context.character.id,
        formatted_table_output,
        "base"
      )
    )
  end
end
