(* ::Package:: *)

(* Remove `Wolfram Mathematica` directory *)
With[
  {dir = FileNameJoin[{$UserDocumentsDirectory, "Wolfram Mathematica"}]},
  If[DirectoryQ[dir], DeleteDirectory[dir]]
];

(* If[
  $FrontEnd =!= Null
  ,
  SetOptions[
    $FrontEnd,
    RulerUnits->"Centimeters",
    PrivateFrontEndOptions -> {
      "LastRegistrationReminderDate" -> None,
      "ShowAtStartup" -> "NewDocument",
      "WolframAlphaSettings" -> {
        "BaseURL" -> "Automatic",
        "SendMathematicaSessionInfo" -> False,
        "AppID" -> Automatic,
        "Autoload" -> False
      }
    },
    PrivateNotebookOptions -> {
      "FinalWindowPrompt" -> False
    },
    CommonDefaultFormatTypes -> {
      "Output" -> TraditionalForm,
      "OutputInline" -> TraditionalForm
    }
  ];
]; *)

Begin["Global`"];

(* Add the command `Enumerate` *)
Enumerate::usage = "Enumerate anything that is indexable.";
Enumerate[l_] := Table[{i, l[[i]]}, {i, Length@l}];
Enumerate[l_, f_]  := Table[{i, f[l[[i]]]}, {i, Length@l}];
Protect[Enumerate];


(* Add `ToNaturalUnits` *)
ToNaturalUnits::usage = "Convert a quantity to natural units (energy).";
Attributes[ToNaturalUnits] = {Listable};
ToNaturalUnits[q_Quantity, base_:"Gigaelectronvolts"] := Block[
  {
    dims,
    l, m, T, t, a,
    c2 = Quantity["SpeedOfLight"]^2,
    hbar = Quantity["ReducedPlanckConstant"],
    hbarc = Quantity["ReducedPlanckConstant"] Quantity["SpeedOfLight"],
    kB = Quantity["BoltzmannConstant"],
    \[Epsilon]0 = Quantity["ElectricConstant"]
  }
  ,
  dims = UnitDimensions[q];
  {l, m, T, t, a} = {
    FirstCase[dims, {"LengthUnit", l_} :> l],
    FirstCase[dims, {"MassUnit", m_} :> m],
    FirstCase[dims, {"TemperatureUnit", T_} :> T],
    FirstCase[dims, {"TimeUnit", t_} :> t],
    FirstCase[dims, {"ElectricCurrentUnit", a_} :> a]
  };
  {l, m, T, t, a} = {l, m, T, t, a} /. Missing[_] :> 0;
  UnitConvert[q hbarc^(-l + a/2) hbar^-t c2^(m - a/2) kB^T (4 \[Pi] \[Epsilon]0)^(-a/2),"Gigaelectronvolts"^(-l - t + m + T + a)]]
Protect[ToNaturalUnits];

(* The following code for interactive plots is taken from Math.SE:
   https://mathematica.stackexchange.com/a/7144/2440
 *)
GetPlotRange::usage = "GetPlotRange[gr] returns the actual unpadded plot range of \
graphics gr. GetPlotRange[gr, True] returns the actual padded plot \
range of gr. GetPlotRange can handle Graphics, Graphics3D and Graph \
objects.";
GetPlotRange[_[gr : (_Graphics | _Graphics3D | _Graph | _GeoGraphics), ___], pad_] := GetPlotRange[gr, pad];(*Handle Legended[\[Ellipsis]] and similar.*)
GetPlotRange[gr_GeoGraphics, False] := (PlotRange /.
   Quiet@AbsoluteOptions@gr);(*TODO:does not handle PlotRangePadding.*)


GetPlotRange[gr_Graph, pad_: False] :=
 Charting`get2DPlotRange[gr, pad];
GetPlotRange[gr : (_Graphics | _Graphics3D), pad_: False] :=
  Module[{r = PlotRange /. Options@gr}, If[MatrixQ[r, NumericQ],
    (*TODO:does not handle PlotRangePadding*)r,
    Last@Last@
      Reap@Rasterize[
        Show[gr, If[pad === False, PlotRangePadding -> None, {}],
         Axes -> True, Frame -> False,
         Ticks -> ((Sow@{##}; Automatic) &),
         DisplayFunction -> Identity, ImageSize -> 0],
        ImageResolution -> 1]]];


(* Joins and filters options, keeping the rightmost if there are \
multiple instances of the same option. *)
filter[opts_List, head_] :=
  Reverse@DeleteDuplicatesBy[
    Reverse@FilterRules[Flatten@opts, First /@ Options@head], First];


(* Find and use SETools of Szabolcs & Halirutan *)
$SEToolsExist =
  FileExistsQ@
   FileNameJoin@{$UserBaseDirectory, "Applications", "SETools",
     "Java", "SETools.jar"};

(* If SETools exist, initiate JLink and include some functions *)
If[$SEToolsExist,
  Needs@"JLink`";
  JLink`InstallJava[];
  copyToClipboard[text_] :=
   Module[{nb}, nb = NotebookCreate[Visible -> False];
    NotebookWrite[nb, Cell[text, "Input"]];
    SelectionMove[nb, All, Notebook];
    FrontEndTokenExecute[nb, "Copy"];
    NotebookClose@nb;
    ];
  uploadButtonAction[img_] :=
   uploadButtonAction[img, "![Mathematica graphics](", ")"];
  uploadButtonAction[img_, wrapStart_String, wrapEnd_String] :=
   Module[{url},
    Check[url = stackImage@img, Return[]];
    copyToClipboard@(wrapStart <> url <> wrapEnd);
    ];
  stackImage::httperr = "Server returned response code: `1`";
  stackImage::err = "Server returner error: `1`";
  stackImage::parseErr = "Could not parse the answer of the server.";
  stackImage[g_] :=
   Module[{url, client, method, data, partSource, part, entity, code,
     response, error, result, parseXMLOutput},
    parseXMLOutput[str_String] :=
     Block[{xml = ImportString[str, {"HTML", "XMLObject"}], result},
      result =
       Cases[xml, XMLElement["script", _, res_] :> StringTrim[res],
         Infinity] /. {{s_String}} :> s;
      If[result =!= {} && StringMatchQ[result, "window.parent" ~~ __],
        Flatten@
        StringCases[result,
         "window.parent." ~~ func__ ~~ "(" ~~ arg__ ~~
           ");" :> {StringMatchQ[func, "closeDialog"],
           StringTrim[arg, "\""]}], $Failed]];
    parseXMLOutput[___] := $Failed;
    data = ExportString[g, "PNG"];
    JLink`JavaBlock[
     JLink`LoadJavaClass["de.halirutan.se.tools.SEUploader",
      StaticsVisible -> True];
     response =
      Check[SEUploader`sendImage@ToCharacterCode@data,
       Return@$Failed]];
    If[response === $Failed, Return@$Failed];
    result = parseXMLOutput@response;
    If[result =!= $Failed,
     If[TrueQ@First@result, Last@result,
      Message[stackImage::err, Last@result]; $Failed],
     Message[stackImage::parseErr]; $Failed]
    ];
  ];


GraphicsButton::usage =
  "GraphicsButton[lbl, gr] represent a button that is labeled with \
lbl and offers functionality for the static graphics object gr. \
GraphicsButton[gr] uses a tiny version of gr as label.";
MenuItems::usage =
  "MenuItems is an option for GraphicsButton that specifies \
additional label \[RuleDelayed] command pairs as a list to be \
included at the top of the action menu of GraphicsButton.";
Options[GraphicsButton] =
  DeleteDuplicatesBy[
   Flatten@{MenuItems -> {}, RasterSize -> Automatic,
     ColorSpace -> Automatic, ImageResolution -> 300,
     Options@ActionMenu}, First];
GraphicsButton[expr_, opts : OptionsPattern[]] :=
  GraphicsButton[
   Pane[expr, ImageSize -> Small, ImageSizeAction -> "ShrinkToFit"],
   expr, opts];
GraphicsButton[lbl_, expr_, opts : OptionsPattern[]] :=
  Module[{head, save, items = OptionValue@MenuItems, rasterizeOpts,
    dir = $UserDocumentsDirectory, file = ""},
   rasterizeOpts =
    filter[{Options@GraphicsButton, opts}, Options@Rasterize];
   save[format_] := (file =
      SystemDialogInput["FileSave",
       FileNameJoin@{dir, "." <> ToLowerCase@format}];
     If[file =!= $Failed && file =!= $Canceled,
      dir = DirectoryName@file;
      Quiet@
       Export[file,
        If[format === "NB", expr,
         Rasterize[expr, "Image", rasterizeOpts]], format]]);
   head = Head@Unevaluated@expr;
   ActionMenu[lbl, Flatten@{
      If[items =!= {}, items, Nothing],
      "Copy expression" :> CopyToClipboard@expr,
      "Copy image" :> CopyToClipboard@Rasterize@expr,
      "Copy high-res image" :>
       CopyToClipboard@Rasterize[expr, "Image", rasterizeOpts],
      "Paste expression" :> Paste@expr,
      "Paste image" :> Paste@Rasterize@expr,
      "Paste high-res image" :>
       Paste@Rasterize[expr, "Image", rasterizeOpts],
      Delimiter,
      "Save as notebook\[Ellipsis]" :> save@"NB",
      "Save as JPEG\[Ellipsis]" :> save@"JPEG",
      "Save as TIFF\[Ellipsis]" :> save@"TIFF",
      "Save as BMP\[Ellipsis]" :> save@"BMP",
      Delimiter,
      Style["Upload image to StackExchange",
        If[$SEToolsExist, Black, Gray]] :>
       If[$SEToolsExist, uploadButtonAction@Rasterize@expr],
      "Open image in external application" :>
       Module[{f =
          Export[FileNameJoin@{$TemporaryDirectory, "temp_img.tiff"},
           Rasterize@expr, "TIFF"]},
        If[StringQ@f && FileExistsQ@f, SystemOpen@f]]
      }, filter[{Options@GraphicsButton, opts, {Method -> "Queued"}},
     Options@ActionMenu]]];


PlotExplorer::usage =
  "PlotExplorer[plot] returns a manipulable version of plot. \
PlotExplorer can handle Graph and Graphics objects and plotting \
functions like Plot, LogPlot, ListPlot, DensityPlot, Streamplot, etc. \
PlotExplorer allows the modification of the plot range, image size \
and aspect ratio. If the supplied argument is a full specification of \
a plotting function holding its first argument (e.g. Plot) the result \
offers functionality to replot the function to the modified plot \
range. PlotExplorer has attribute HoldFirst.";
AppearanceFunction::usage =
  "AppearanceFunction is an option for PlotExplorer that specifies \
the appearance function of the menu button. Use Automatic for the \
default appearance, Identity to display a classic button or None to \
omit the menu button.";
MenuPosition::usage =
  "MenuPosition is an option for PlotExplorer that specifies the \
position of the (upper right corner of the) menu button within the \
graphics object.";
Attributes[PlotExplorer] = {HoldFirst};
Options[PlotExplorer] = {AppearanceFunction -> (Mouseover[
         Invisible@#, #] &@
       Framed[#, Background -> GrayLevel[.5, .5], RoundingRadius -> 5,
         FrameStyle -> None, Alignment -> {Center, Center},
        BaseStyle -> {FontFamily -> "Helvetica"}] &),
   MenuPosition -> Scaled@{1, 1}};
PlotExplorer[expr_, rangeArg_: Automatic, sizeArg_: Automatic,
   ratioArg_: Automatic, opts : OptionsPattern[]] :=
  Module[{plot = expr, held = Hold@expr, head, holdQ = True,
    legQ = False, appearance,
    position, $1Dplots =
     Plot | LogPlot | LogLinearPlot | LogLogPlot, $2Dplots =
     DensityPlot | ContourPlot | RegionPlot | StreamPlot |
      StreamDensityPlot | VectorPlot | VectorDensityPlot |
      LineIntegralConvolutionPlot | GeoGraphics}, head = held[[1, 0]];
   If[head === Symbol, holdQ = False; head = Head@expr];
   If[head === Legended, legQ = True;
    If[holdQ, held = held /. Legended[x_, ___] :> x;
     head = held[[1, 0]], head = Head@First@expr]];
   holdQ = holdQ && MatchQ[head, $1Dplots | $2Dplots];
   If[! holdQ, legQ = Head@expr === Legended;
    head = If[legQ, Head@First@expr, Head@expr]];
   If[Not@MatchQ[head, $1Dplots | $2Dplots | Graphics | Graph], expr,
    DynamicModule[{dyn, gr, leg, replot, rescale, new, mid, len,
      min = 0.1, f = {1, 1}, set, d, epilog, over = False, defRange,
      range, size, ratio, pt1, pt1sc = None, pt2 = None, pt2sc = None,
       rect, button}, {gr, leg} = If[legQ, List @@ plot, {plot, None}];
     size =
      If[sizeArg === Automatic, Rasterize[gr, "RasterSize"],
       Setting@sizeArg];
     defRange =
      If[rangeArg === Automatic, GetPlotRange[gr, False],
       Setting@rangeArg];
     ratio =
      If[ratioArg === Automatic, Divide @@ Reverse@size,
       Setting@ratioArg];
     epilog = Epilog /. Quiet@AbsoluteOptions@plot;
     gr = plot;
     (*When r1 or r2 is e.g.{1,1} (scale region has zero width),
     EuclideanDistance by default returns Infinity which is fine.*)
     d[p1_, p2_, {r1_, r2_}] :=
      Quiet@N@EuclideanDistance[Rescale[p1, r1], Rescale[p2, r2]];
     set[r_] := (range = new = r; mid = Mean /@ range;
       len = Abs[Subtract @@@ range]; pt1 = None; rect = {};);
     set@defRange;
     (*Replace plot range or insert if nonexistent*)
     replot[h_, hold_, r_] :=
      Module[{temp},
       ReleaseHold@
        Switch[h, $1Dplots,
         temp = ReplacePart[
           hold, {{1, 2, 2} -> r[[1, 1]], {1, 2, 3} -> r[[1, 2]]}];
         If[MemberQ[temp, PlotRange, Infinity],
          temp /. {_[PlotRange, _] -> (PlotRange -> r)},
          Insert[temp, PlotRange -> r, {1, -1}]], $2Dplots,
         temp = ReplacePart[
           hold, {{1, 2, 2} -> r[[1, 1]], {1, 2, 3} ->
             r[[1, 2]], {1, 3, 2} -> r[[2, 1]], {1, 3, 3} ->
             r[[2, 2]]}];
         If[MemberQ[temp, PlotRange, Infinity],
          temp /. {_[PlotRange, _] -> (PlotRange -> r)},
          Insert[temp, PlotRange -> r, {1, -1}]], _, hold]];
     rescale[h_, hold_, sc_] :=
      ReleaseHold@
       Switch[h, $1Dplots | $2Dplots,
        If[MemberQ[hold, ScalingFunctions, Infinity],
         hold /. {_[ScalingFunctions, _] -> (ScalingFunctions -> sc)},
          Insert[hold, ScalingFunctions -> sc, {1, -1}]], _, hold];
     appearance =
      OptionValue@
        AppearanceFunction /. {Automatic :> (AppearanceFunction /.
           Options@PlotExplorer)};
     position = OptionValue@MenuPosition /. Automatic -> Scaled@{1, 1};
     (*Print@Column@{rangeArg,sizeArg,ratioArg,appearance,position};*)
     button =
      If[appearance === None, {},
       Inset[appearance@
         Dynamic@GraphicsButton["Menu", dyn,
           Appearance -> If[appearance === Identity, Automatic, None],
            MenuItems ->
            Flatten@{{Row@{"Copy PlotRange \[Rule] ",
                  TextForm /@ range} :> (CopyToClipboard[
                  PlotRange -> range]),
               Row@{"Copy ImageSize \[Rule] ",
                  InputForm@size} :> (CopyToClipboard[
                  ImageSize -> size]),
               Row@{"Copy AspectRatio \[Rule] ",
                  InputForm@ratio} :> (CopyToClipboard[
                  AspectRatio -> ratio])},
              If[MatchQ[head, $1Dplots | $2Dplots], {Delimiter,
                "Replot at current PlotRange" :> (gr =
                    replot[head, held, range];),
                "Linear" :> {gr =
                    rescale[head, held, {Identity, Identity}];},
                "Log" :> {gr =
                   rescale[head, held, {Identity, "Log"}]},
                "LogLinear" :> {gr =
                   rescale[head, held, {"Log", Identity}]},
                "LogLog" :> {gr =
                   rescale[head, held, {"Log", "Log"}]}}, {}],
              Delimiter}], position, Scaled@{1, 1},
        Background -> None]];
     Deploy@Pane[EventHandler[Dynamic[MouseAppearance[Show[
           (*`dyn` is kept as the original expression with only \
updating `range`,`size` and `ratio`.*)
           dyn = Show[gr, PlotRange -> Dynamic@range,
             ImageSize -> Dynamic@size, AspectRatio -> Dynamic@ratio],

           Epilog -> {epilog,
             button, {FaceForm@{Blue, Opacity@.1},
              EdgeForm@{Thin, Dotted, Opacity@.5},
              Dynamic@rect}, {Dynamic@
               If[over && CurrentValue@"AltKey" &&
                 pt2 =!= None, {Antialiasing -> False,
                 AbsoluteThickness@.25, GrayLevel[.5, .5], Dashing@{},
                  InfiniteLine@{pt2, pt2 + {1, 0}},
                 InfiniteLine@{pt2, pt2 + {0, 1}}}, {}]}}],
          Which[over && CurrentValue@"AltKey" && pt2 =!= None,
           Graphics@{Text[pt2, pt2, -{1.1, 1},
              Background -> GrayLevel[1, .7]]},
           CurrentValue@"ShiftKey", "LinkHand",
           CurrentValue@"ControlKey", "ZoomView", True, Automatic]],
         TrackedSymbols :> {gr}], {"MouseEntered" :> (over = True),
         "MouseExited" :> (over = False),
         "MouseMoved" :> (pt2 = MousePosition@"Graphics";),
         "MouseClicked" :> (If[CurrentValue@"MouseClickCount" == 2,
             set@defRange];),
         "MouseDown" :> (pt1 = MousePosition@"Graphics";
           pt1sc = MousePosition@"GraphicsScaled";),
         "MouseUp" :> (If[
            CurrentValue@"ControlKey" && d[pt1, pt2, new] > min,
            range = Transpose@Sort@{pt1, pt2};]; set@range;),
         "MouseDragged" :> (pt2 = MousePosition@"Graphics";
           pt2sc = MousePosition@"GraphicsScaled";

           Which[CurrentValue@"ShiftKey",
            pt2 = MapThread[
               Rescale, {MousePosition@
                 "GraphicsScaled", {{0, 1}, {0, 1}}, new}] - pt1;
            range = new - pt2;,(*Panning*)CurrentValue@"ControlKey",
            rect = If[pt1 === None || pt2 === None, {},
               Rectangle[pt1, pt2]];,(*Zooming rectangle*)True,
            f = 10^(pt1sc - pt2sc);

            range = (mid + (1 - f) (pt1 - mid)) +
              f/2 {-len, len}\[Transpose](*Zofom on `pt1`*)])},
        PassEventsDown -> True, PassEventsUp -> True],
       Dynamic[size, (size = #;

          If[CurrentValue@"ControlKey",
           ratio = Divide @@ Reverse@#]) &],
       AppearanceElements -> "ResizeArea", ImageMargins -> 0,
       FrameMargins -> 0]]]];


(* Add Magma, Plasma, Inferno and Viridis colormaps *)
(* ; codespell:ignore:start
*)
Magma=Blend[Uncompress["1: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"(* codespell:ignore *)
<>"2qJ5zGjYAVlFoyrxcCXpq50RfNgrZqIc2KlV+bAa/ElAXAzPx6k456KE6fyWJf007ZS\
GS8T+cByNR8BrF1bEko/rcTAK/VUy0eJgGf2xp4y+AXiqun+sbSPo//b9aUAXgmd5+k\
IoH2zxJJ0/l0fYBbAx1Uyr8DXpKgzEVQPCun60U/AFjCpuVGsgDE5K+dWmJ1vSgW3+H\
87s8XwJ4mlCEj4MHIPWOEOBpqPNedyAwbBJx8tWwXYyzlL89UCwp7o7iNdVKhfoiykY\
y2chZ0AF5JLl0oPkulQ79+GPBQ+I+rEmyQfJsFX5cJiKNJk2HlJ1OAV1ZOCzCz3gZDA\
TxKs7y/edBtBDB19x6DPQGAP3+XHnH5gmIj+xPcm78DHtg5e/3Gx6H/fs2CTiEy5X8n\
alAw5Rcn5TQQZl12ngjNePj/44ZItWYmOcBGMuld8TMorsmXS5OiYKVYPn2Jm4D/Qpb\
QwWeMn7RvHiqlfEDFC9LOZjmAE/9Ir5o/h+LS+eZsdQp+OhHfcWMccGx4zgCnH4rLdt\
tNBVLWeY0X40FPIQiz3/rpnjYVoFjsZf3FsG+Az/CHuARfAixDF0THMYrifzUc8AnH1\
Zou8YB9/LubWrb1Y1hBzW2VKGXXKahuFnXrAhzme36VmBaKKZOvYcp+JiBent4M+bT2\
TOXHMXcU2/3Kl1Wg3CmTYS3XZU8Ctqr5cfdIHoqZV3o+wB32nRwsASP/DQ1Q/BiyRFr\
P+P8axXLAXcXbknW4BzBMUKUcj+4GfNzSnDaLGiKnxPzlKE4dFLuN5Fh7UIoMb9f8bc\
vDgIXK56O07qKYMtznopSvzFH3EkkHwMt3GOiZC1EcFZpW1tgCuP4tl31vNuBGXuX6v\
b9RHFQ5sMzbBPjfqApwt6fzpR6hL+hgobXn2fMGwG48qedlBSFFiu79fr/bGMWclPOH\
Uvm9nBYYF40BU610eCheedZfDfj2oIKTXzTgUIWxnRqNKFapTLVbWzH+X1gDHJfu4fF\
u9Vd0CnHP2lPpA+CIHZQnV5D1zuRI111VRLF18TcfllLAtV8pUQHwv+EniuXZpKzFig\
AzZ/5gH/UGHL24GQIlihPeLTgOvwHckrHaIrAEMKu6IaP0OIqpNccHll4Bfpf8OZNmE\
bBZzC8X292DGF55GkhpIVi+xns+PAAhy+379qPipijWKtXoKnoBuHo67+EaW8DBYtCN\
xqFYhlfd2YPSyaRbbZ+MSAWc2Ug5PlFMfCl1C04DrOV3emzVEOBUh1fbODYPYXjl46Q\
Afq5KCQaQFGhan+tv1EZxljRDvedTwKZ6UeUzeoBNdyZ1HA5Cce68a0vIE8A3D+8lro\
UDHqjleJtZheKVn7bGAzY+QO09WA+4W3jqtD7DNwxP1VQbz8YA5lRljzq9Bl7k3GNbP\
HAUxSF5vwSFosD4L/A5tB+l1AR3qcSTbigO7hKJS4sEo7z2UICaK7zw5iEXnApR/PXS\
8T0T4WCsDClPeODFxEaGhvE/34j/A7Hqa4E="],#]&;
Inferno=Blend[Uncompress["1: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"],#]&;
Plasma=Blend[Uncompress["1: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\
H8t1TbI="],#]&;
Viridis=Blend[Uncompress["1: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"(* codespell:ignore *)
<>"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\
Z/NK4v8Arrpjag=="],#]&;
Protect[Magma, Inferno, Plasma, Viridis];
(* ; codespell:ignore:end
*)

End[];
