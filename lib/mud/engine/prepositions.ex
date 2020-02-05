defmodule Mud.Engine.Prepositions do
  alias Mud.Engine.Preposition

  def aboard(), do: :aboard
  def about(), do: :about
  def above(), do: :above
  def according_to(), do: :according_to
  def across(), do: :across
  def across_from(), do: :across_from
  def against(), do: :against
  def ahead_of(), do: :ahead_of
  def along(), do: :along
  def amid(), do: :amid
  def among(), do: :among
  def anti(), do: :anti
  def apart(), do: :apart
  def around(), do: :around
  def as(), do: :as
  def as_for(), do: :as_for
  def as_of(), do: :as_of
  def as_per(), do: :as_per
  def as_regards(), do: :as_regards
  def as_to(), do: :as_to
  def as_well_as(), do: :as_well_as
  def aside(), do: :aside
  def astride(), do: :astride
  def at(), do: :at
  def atop(), do: :atop
  def away_from(), do: :away_from
  def back_to(), do: :back_to
  def barring(), do: :barring
  def based_on(), do: :based_on
  def because_of(), do: :because_of
  def before(), do: :before
  def behind(), do: :behind
  def beyond(), do: :beyond
  def but(), do: :but
  def but_for(), do: :but_for
  def by(), do: :by
  def circa(), do: :circa
  def concerning(), do: :concerning
  def considering(), do: :considering
  def contrary_to(), do: :contrary_to
  def counter_to(), do: :counter_to
  def counting(), do: :counting
  def depending_on(), do: :depending_on
  def down(), do: :down
  def due_to(), do: :due_to
  def during(), do: :during
  def except(), do: :except
  def far_from(), do: :far_from
  def following(), do: :following
  def forr(), do: :for
  def forward_of(), do: :forward_of
  def from(), do: :from
  def further_to(), do: :further_to
  def given(), do: :given
  def inside(), do: :inside
  def in_addition_to(), do: :in_addition_to
  def between(), do: :between
  def in_case_of(), do: :in_case_of
  def in_front_of(), do: :in_front_of
  def despite(), do: :despite
  def in_view_of(), do: :in_view_of
  def including(), do: :including
  def instead_of(), do: :instead_of
  def left_of(), do: :left_of
  def less(), do: :less
  def like(), do: :like
  def minus(), do: :minus
  def near(), do: :near
  def beside(), do: :beside
  def of(), do: :of
  def off(), do: :off
  def on(), do: :on
  def on_account_of(), do: :on_account_of
  def on_behalf_of(), do: :on_behalf_of
  def on_board(), do: :on_board
  def on_to(), do: :on_to
  def onto(), do: :onto
  def on_top_of(), do: :on_top_of
  def opposite(), do: :opposite
  def other_than(), do: :other_than
  def out_from(), do: :out_from
  def out_of(), do: :out_of
  def outside(), do: :outside
  def over(), do: :over
  def owing_to(), do: :owing_to
  def past(), do: :past
  def pending(), do: :pending
  def plus(), do: :plus
  def prior_to(), do: :prior_to
  def pro(), do: :pro
  def instead(), do: :instead
  def regarding(), do: :regarding
  def regardless_of(), do: :regardless_of
  def respecting(), do: :respecting
  def right_of(), do: :right_of
  def round(), do: :round
  def save(), do: :save
  def save_for(), do: :save_for
  def saving(), do: :saving
  def since(), do: :since
  def subsequent_to(), do: :subsequent_to
  def such_as(), do: :such_as
  def than(), do: :than
  def thanks_to(), do: :thanks_to
  def through(), do: :through
  def throughout(), do: :throughout
  def thru(), do: :thru
  def till(), do: :till
  def to(), do: :to
  def together_with(), do: :together_with
  def touching(), do: :touching
  def towards(), do: :towards
  def beneath(), do: :beneath
  def unlike(), do: :unlike
  def until(), do: :until
  def up(), do: :up
  def up_against(), do: :up_against
  def upon(), do: :upon
  def up_to(), do: :up_to
  def up_until(), do: :up_until
  def using(), do: :using
  def versus(), do: :versus
  def via(), do: :via
  def with_reference_to(), do: :with_reference_to
  def with_regard_to(), do: :with_regard_to
  def without(), do: :without
  def worth(), do: :worth
  def prepositions(), do: [
  %Preposition{matchstrings: ["aboard"], preposition: "aboard", raw_input: nil, token: :aboard},
  %Preposition{matchstrings: ["about"], preposition: "about", raw_input: nil, token: :about},
  %Preposition{matchstrings: ["above"], preposition: "above", raw_input: nil, token: :above},
  %Preposition{matchstrings: ["accordingto", "according to"], preposition: "according to", raw_input: nil, token: :according_to},
  %Preposition{matchstrings: ["across"], preposition: "across", raw_input: nil, token: :across},
  %Preposition{matchstrings: ["acrossfrom", "across from"], preposition: "across from", raw_input: nil, token: :across_from},
  %Preposition{matchstrings: ["after"], preposition: "after", raw_input: nil, token: :after},
  %Preposition{matchstrings: ["against"], preposition: "against", raw_input: nil, token: :against},
  %Preposition{matchstrings: ["aheadof", "ahead of"], preposition: "ahead of", raw_input: nil, token: :ahead_of},
  %Preposition{matchstrings: ["alongwith", "along with", "along"], preposition: "along with", raw_input: nil, token: :along},
  %Preposition{matchstrings: ["amidst", "amid"], preposition: "amidst", raw_input: nil, token: :amid},
  %Preposition{matchstrings: ["amongst", "among"], preposition: "amongst", raw_input: nil, token: :among},
  %Preposition{matchstrings: ["anti"], preposition: "anti", raw_input: nil, token: :anti},
  %Preposition{matchstrings: ["apartfrom", "apart from"], preposition: "apart from", raw_input: nil, token: :apart},
  %Preposition{matchstrings: ["around"], preposition: :around, raw_input: nil, token: :around},
  %Preposition{matchstrings: ["as"], preposition: "as", raw_input: nil, token: :as},
  %Preposition{matchstrings: ["asfor", "as for"], preposition: "as for", raw_input: nil, token: :as_for},
  %Preposition{matchstrings: ["asidefrom", "aside from"], preposition: "aside from", raw_input: nil, token: :aside},
  %Preposition{matchstrings: ["asof", "as of"], preposition: "as of", raw_input: nil, token: :as_of},
  %Preposition{matchstrings: ["asper", "as per"], preposition: "as per", raw_input: nil, token: :as_per},
  %Preposition{matchstrings: ["asregards", "as regards"], preposition: "as regards", raw_input: nil, token: :as_regards},
  %Preposition{matchstrings: ["asto", "as to"], preposition: "asto", raw_input: nil, token: :as_to},
  %Preposition{matchstrings: ["astride"], preposition: "astride", raw_input: nil, token: :astride},
  %Preposition{matchstrings: ["aswellas", "aswell as", "as wellas", "as well as"], preposition: "as well as", raw_input: nil, token: :as_well_as},
  %Preposition{matchstrings: ["at"], preposition: "at", raw_input: nil, token: :at},
  %Preposition{matchstrings: ["atop"], preposition: "atop", raw_input: nil, token: :atop},
  %Preposition{matchstrings: ["awayfrom", "away from"], preposition: "away from", raw_input: nil, token: :away_from},
  %Preposition{matchstrings: ["backto", "back to"], preposition: "back to", raw_input: nil, token: :back_to},
  %Preposition{matchstrings: ["barring", "bar"], preposition: "barring", raw_input: nil, token: :barring},
  %Preposition{matchstrings: ["basedon", "based on"], preposition: "based on", raw_input: nil, token: :based_on},
  %Preposition{matchstrings: ["becauseof", "because of"], preposition: "because of", raw_input: nil, token: :because_of},
  %Preposition{matchstrings: ["before"], preposition: "before", raw_input: nil, token: :before},
  %Preposition{matchstrings: ["behind"], preposition: "behind", raw_input: nil, token: :behind},
  %Preposition{matchstrings: ["besides"], preposition: "besides", raw_input: nil, token: :besides},
  %Preposition{matchstrings: ["beyond"], preposition: "beyond", raw_input: nil, token: :beyond},
  %Preposition{matchstrings: ["but"], preposition: "but", raw_input: nil, token: :but},
  %Preposition{matchstrings: ["butfor", "but for"], preposition: "but for", raw_input: nil, token: :but_for},
  %Preposition{matchstrings: ["by"], preposition: "by", raw_input: nil, token: :by},
  %Preposition{matchstrings: ["byusing", "by using", "bymeansof", "bymeans of", "by meansof", "by means of"], preposition: "by using", raw_input: nil, token: :by_using},
  %Preposition{matchstrings: ["circa"], preposition: "circa", raw_input: nil, token: :circa},
  %Preposition{matchstrings: ["concerning"], preposition: "concerning", raw_input: nil, token: :concerning},
  %Preposition{matchstrings: ["considering"], preposition: "considering", raw_input: nil, token: :considering},
  %Preposition{matchstrings: ["counterto", "counter to", "contraryto", "contrary to"], preposition: "counter to", raw_input: nil, token: :contrary_to},
  %Preposition{matchstrings: ["counting"], preposition: "counting", raw_input: nil, token: :counting},
  %Preposition{matchstrings: ["dependingon", "depending on"], preposition: "depending on", raw_input: nil, token: :depending_on},
  %Preposition{matchstrings: ["down"], preposition: "down", raw_input: nil, token: :down},
  %Preposition{matchstrings: ["dueto", "due to"], preposition: "due to", raw_input: nil, token: :due_to},
  %Preposition{matchstrings: ["during"], preposition: "during", raw_input: nil, token: :during},
  %Preposition{matchstrings: ["excluding", "excepting", "exceptfor", "except for", "except"], preposition: "excluding", raw_input: nil, token: :except},
  %Preposition{matchstrings: ["farfrom", "far from"], preposition: "far from", raw_input: nil, token: :far_from},
  %Preposition{matchstrings: ["following"], preposition: "following", raw_input: nil, token: :following},
  %Preposition{matchstrings: ["for"], preposition: "for", raw_input: nil, token: :for},
  %Preposition{matchstrings: ["forwardsof", "forwards of", "forwardof", "forward of"], preposition: "forwards of", raw_input: nil, token: :forward_of},
  %Preposition{matchstrings: ["from"], preposition: "from", raw_input: nil, token: :from},
  %Preposition{matchstrings: ["furtherto", "further to"], preposition: "further to", raw_input: nil, token: :further_to},
  %Preposition{matchstrings: ["given"], preposition: "given", raw_input: nil, token: :given},
  %Preposition{matchstrings: ["in"], preposition: "in", raw_input: nil, token: :in},
  %Preposition{matchstrings: ["inadditionto", "inaddition to", "in additionto", "in addition to"], preposition: "in addition to", raw_input: nil, token: :in_addition_to},
  %Preposition{matchstrings: ["inbetween", "in between", "between"], preposition: "in between", raw_input: nil, token: :between},
  %Preposition{matchstrings: ["incaseof", "incase of", "in caseof", "in case of"], preposition: "in case of", raw_input: nil, token: :in_case_of},
  %Preposition{matchstrings: ["including"], preposition: "including", raw_input: nil, token: :including},
  %Preposition{matchstrings: ["infrontof", "infront of", "in frontof", "in front of"], preposition: "in front of", raw_input: nil, token: :in_front_of},
  %Preposition{matchstrings: ["inspiteof", "inspite of", "in spiteof", "in spite of", "despite"], preposition: "in spite of", raw_input: nil, token: :despite},
  %Preposition{matchstrings: ["insteadof", "instead of"], preposition: "instead of", raw_input: nil, token: :instead_of},
  %Preposition{matchstrings: ["inviewof", "inview of", "in viewof", "in view of"], preposition: "in view of", raw_input: nil, token: :in_view_of},
  %Preposition{matchstrings: ["leftof", "left of"], preposition: "left of", raw_input: nil, token: :left_of},
  %Preposition{matchstrings: ["less"], preposition: "less", raw_input: nil, token: :less},
  %Preposition{matchstrings: ["like"], preposition: "like", raw_input: nil, token: :like},
  %Preposition{matchstrings: ["minus"], preposition: "minus", raw_input: nil, token: :minus},
  %Preposition{matchstrings: ["nearto", "near to", "near", "closeto", "close to"], preposition: "near to", raw_input: nil, token: :near},
  %Preposition{matchstrings: ["nextto", "next to", "beside", "alongside", "adjacentto", "adjacent to"], preposition: "next to", raw_input: nil, token: :beside},
  %Preposition{matchstrings: ["of"], preposition: "of", raw_input: nil, token: :of},
  %Preposition{matchstrings: ["off"], preposition: "off", raw_input: nil, token: :off},
  %Preposition{matchstrings: ["on"], preposition: "on", raw_input: nil, token: :on},
  %Preposition{matchstrings: ["on to"], preposition: "on to", raw_input: nil, token: :on_to},
  %Preposition{matchstrings: ["onaccountof", "onaccount of", "on accountof", "on account of"], preposition: "on account of", raw_input: nil, token: :on_account_of},
  %Preposition{matchstrings: ["onbehalfof", "onbehalf of", "on behalfof", "on behalf of"], preposition: "on behalf of", raw_input: nil, token: :on_behalf_of},
  %Preposition{matchstrings: ["onboard", "on board"], preposition: "on board", raw_input: nil, token: :on_board},
  %Preposition{matchstrings: ["onto"], preposition: "on to", raw_input: nil, token: :onto},
  %Preposition{matchstrings: ["ontopof", "ontop of", "on topof", "on top of"], preposition: "on top of", raw_input: nil, token: :on_top_of},
  %Preposition{matchstrings: ["oppositeto", "opposite to", "oppositeof", "opposite of", "opposite"], preposition: "opposite to", raw_input: nil, token: :opposite},
  %Preposition{matchstrings: ["otherthan", "other than"], preposition: "other than", raw_input: nil, token: :other_than},
  %Preposition{matchstrings: ["outfrom", "out from"], preposition: "out from", raw_input: nil, token: :out_from},
  %Preposition{matchstrings: ["outof", "out of"], preposition: "out of", raw_input: nil, token: :out_of},
  %Preposition{matchstrings: ["outsideof", "outside of", "outside"], preposition: "outside of", raw_input: nil, token: :outside},
  %Preposition{matchstrings: ["over"], preposition: "over", raw_input: nil, token: :over},
  %Preposition{matchstrings: ["owingto", "owing to"], preposition: "owing to", raw_input: nil, token: :owing_to},
  %Preposition{matchstrings: ["past"], preposition: "past", raw_input: nil, token: :past},
  %Preposition{matchstrings: ["pending"], preposition: "pending", raw_input: nil, token: :pending},
  %Preposition{matchstrings: ["plus"], preposition: "plus", raw_input: nil, token: :plus},
  %Preposition{matchstrings: ["priorto", "prior to"], preposition: "prior to", raw_input: nil, token: :prior_to},
  %Preposition{matchstrings: ["pro", "infavorof", "infavor of", "in favorof", "in favor of"], preposition: "pro", raw_input: nil, token: :pro},
  %Preposition{matchstrings: ["ratherthan", "rather than", "inlieuof", "inlieu of", "in lieuof", "in lieu of"], preposition: "rather than", raw_input: nil, token: :instead},
  %Preposition{matchstrings: ["regarding"], preposition: "regarding", raw_input: nil, token: :regarding},
  %Preposition{matchstrings: ["regardlessof", "regardless of"], preposition: "regardless of", raw_input: nil, token: :regardless_of},
  %Preposition{matchstrings: ["respecting"], preposition: "respecting", raw_input: nil, token: :respecting},
  %Preposition{matchstrings: ["rightof", "right of"], preposition: "right of", raw_input: nil, token: :right_of},
  %Preposition{matchstrings: ["round"], preposition: "round", raw_input: nil, token: :round},
  %Preposition{matchstrings: ["save"], preposition: "save", raw_input: nil, token: :save},
  %Preposition{matchstrings: ["savefor", "save for"], preposition: "save for", raw_input: nil, token: :save_for},
  %Preposition{matchstrings: ["saving"], preposition: "saving", raw_input: nil, token: :saving},
  %Preposition{matchstrings: ["since"], preposition: "since", raw_input: nil, token: :since},
  %Preposition{matchstrings: ["subsequentto", "subsequent to"], preposition: "subsequent to", raw_input: nil, token: :subsequent_to},
  %Preposition{matchstrings: ["suchas", "such as"], preposition: "such as", raw_input: nil, token: :such_as},
  %Preposition{matchstrings: ["than"], preposition: "than", raw_input: nil, token: :than},
  %Preposition{matchstrings: ["thanksto", "thanks to"], preposition: "thanks to", raw_input: nil, token: :thanks_to},
  %Preposition{matchstrings: ["through"], preposition: "through", raw_input: nil, token: :through},
  %Preposition{matchstrings: ["throughout"], preposition: "throughout", raw_input: nil, token: :throughout},
  %Preposition{matchstrings: ["thru"], preposition: "thru", raw_input: nil, token: :thru},
  %Preposition{matchstrings: ["till"], preposition: "till", raw_input: nil, token: :till},
  %Preposition{matchstrings: ["to"], preposition: "to", raw_input: nil, token: :to},
  %Preposition{matchstrings: ["togetherwith", "together with"], preposition: "together with", raw_input: nil, token: :together_with},
  %Preposition{matchstrings: ["touching"], preposition: "touching", raw_input: nil, token: :touching},
  %Preposition{matchstrings: ["towards"], preposition: "towards", raw_input: nil, token: :towards},
  %Preposition{matchstrings: ["underneath", "under", "beneath", "below"], preposition: "underneath", raw_input: nil, token: :beneath},
  %Preposition{matchstrings: ["unlike"], preposition: "unlike", raw_input: nil, token: :unlike},
  %Preposition{matchstrings: ["until"], preposition: "until", raw_input: nil, token: :until},
  %Preposition{matchstrings: ["up"], preposition: "up", raw_input: nil, token: :up},
  %Preposition{matchstrings: ["upagainst", "up against"], preposition: "upagainst", raw_input: nil, token: :up_against},
  %Preposition{matchstrings: ["upon"], preposition: "upon", raw_input: nil, token: :upon},
  %Preposition{matchstrings: ["upto", "up to"], preposition: "upto", raw_input: nil, token: :up_to},
  %Preposition{matchstrings: ["upuntil", "up until"], preposition: "upuntil", raw_input: nil, token: :up_until},
  %Preposition{matchstrings: ["versus"], preposition: "versus", raw_input: nil, token: :versus},
  %Preposition{matchstrings: ["via"], preposition: "via", raw_input: nil, token: :via},
  %Preposition{matchstrings: ["with"], preposition: "with", raw_input: nil, token: :with},
  %Preposition{matchstrings: ["within", "into", "insideof", "inside of", "inside"], preposition: "within", raw_input: nil, token: :inside},
  %Preposition{matchstrings: ["without"], preposition: "without", raw_input: nil, token: :without},
  %Preposition{matchstrings: ["withreferenceto", "withreference to", "with referenceto", "with reference to"], preposition: "with reference to", raw_input: nil, token: :with_reference_to},
  %Preposition{matchstrings: ["withregardsto", "withregards to", "with regardsto", "with regards to", "withregardto", "withregard to", "with regardto", "with regard to"], preposition: "with regard to", raw_input: nil, token: :with_regard_to},
  %Preposition{matchstrings: ["worth"], preposition: "worth", raw_input: nil, token: :worth}
  ]
end
