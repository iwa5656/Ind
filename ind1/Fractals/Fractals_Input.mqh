//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type4   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color4  clrMagenta
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width4  1
//---- displaying of the bullish label of the indicator
#property indicator_label4  "Up Fractal"
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type5   DRAW_ARROW
//---- blue color is used as the color of a bullish candlestick
#property indicator_color5  clrBlue
//---- indicator 2 line width is equal to 1
#property indicator_width5  1
//---- displaying of the bearish label of the indicator
#property indicator_label5 "Down Fractal"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int  UpLable=119;//upper fractal label
input int  DnLable=119;//lower fractal label
input bool ShowPrice=true;
input uint nSize=1;
input color UpColor=clrTeal;
input color DnColor=clrRed;