//+------------------------------------------------------------------+
//|                                                 PendingOrder.mq4 |
//|                                                     Hamza Shafiq |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Hamza Shafiq"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input double PointDiffernce = 3;
input int MAGICNUM = 20131111;
input double TotalOrder     = 10;
input double StopLoss       =0.50;
extern bool removeFromThisChartOnly = true;
long ChartColor;
string LastLine2;
string BackgroundName;
int TotalGBuyOrder=0;
int TotalGSellOrder=0;
int TotalGPBuyOrder=0;
int TotalGPSellOrder=0;
int TotalOrderPair=0;
double TotalProfit=0;
input string CurrencyPair="XAUUSDm";
string EuroPair="EURUSDm";
string JPYPair="USDJPYm";
string GBPPair="GBPUSDm";
string US30Pair="US30m";
string CADPair="USDCADm";
string NASPair="USTECm";
extern bool      UseTimeFilter       = true;
extern string    TimeStartTrade      = "20:00:00";
extern string    TimeStopTrade       = "22:00:00";
bool TimeToTrade;
double LotSize;
extern double    Risk          = 10.0;//Percent Risk
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ChartColor=ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   BackgroundName="Background-"+WindowExpertName();
   ChartBackground(BackgroundName,(color)ChartColor,0,15,300,80);
   LastLine2=CurrencyPair+" Trading Boot";
   ObjectCreate("LastLine2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("LastLine2", OBJPROP_CORNER,0);
   ObjectSet("LastLine2", OBJPROP_XDISTANCE,10);
   ObjectSet("LastLine2", OBJPROP_YDISTANCE,20);
   ObjectSetText("LastLine2",LastLine2,14,"Tohoma",White);
   EventSetTimer(10);
//---
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChartBackground(string StringName,color ImageColor,int Xposition,int Yposition,int Xsize,int Ysize)
  {
//---------------------------------------------------------------------
   if(ObjectFind(0,StringName)==-1)
     {
      ObjectCreate(0,StringName,OBJ_RECTANGLE_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,StringName,OBJPROP_XDISTANCE,Xposition);
      ObjectSetInteger(0,StringName,OBJPROP_YDISTANCE,Yposition);
      ObjectSetInteger(0,StringName,OBJPROP_XSIZE,Xsize);
      ObjectSetInteger(0,StringName,OBJPROP_YSIZE,Ysize);
      ObjectSetInteger(0,StringName,OBJPROP_BGCOLOR,Green);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,StringName,OBJPROP_BORDER_COLOR,Purple);
      ObjectSetInteger(0,StringName,OBJPROP_BACK,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,StringName,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,StringName,OBJPROP_HIDDEN,false);
      ObjectSetInteger(0,StringName,OBJPROP_ZORDER,0);
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int differnce=0;
int stopeLoss=0;
void OnTick()
  {
   if(UseTimeFilter==true)
     {
      TimeToTrade=true;
      //---
      if((StringToTime(TimeStartTrade)<StringToTime(TimeStopTrade))&&((TimeGMT()>=StringToTime(TimeStartTrade))&&(TimeGMT()<StringToTime(TimeStopTrade))))
         TimeToTrade=true;
      if((StringToTime(TimeStartTrade)>StringToTime(TimeStopTrade))&&((TimeGMT()>=StringToTime(TimeStartTrade))||(TimeGMT()<StringToTime(TimeStopTrade))))
         TimeToTrade=true;
      //---
      if(TimeToTrade==true)
        {
         CheckOpenOrders();
         OrderOpen();
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderOpen()
  {
   if(TotalOrderPair<TotalOrder)
     {
      double BidPrice = MarketInfo(CurrencyPair, MODE_BID);
      double AskPrice = MarketInfo(CurrencyPair, MODE_ASK);
      differnce=PointDiffernce+differnce;
      openOrder(CurrencyPair,AskPrice,differnce);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void openOrder(string pair,double PairAskPrice,double PairDiffernce)
  {
   bool res;
   double buyAsk=(PairAskPrice+PairDiffernce);
   double sellAsk=(PairAskPrice-PairDiffernce);

   res=OrderSend(pair,OP_BUYSTOP,getLot(),buyAsk,0,NULL,NULL);
   res=OrderSend(pair,OP_SELLSTOP,getLot(),sellAsk,0,NULL,NULL);
   if(!res)
      Print("Error in OrderModify. Error code=",GetLastError());
   else
      Print("Order openOrder successfully."+pair+(PairAskPrice+PairDiffernce));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLot()
  {
  // return 0.01;
   return MathMin(MathMax((MathRound((AccountFreeMargin()*Risk/100000)/MarketInfo(CurrencyPair,MODE_LOTSTEP))*MarketInfo(CurrencyPair,MODE_LOTSTEP)),MarketInfo(CurrencyPair,MODE_MINLOT)),MarketInfo(CurrencyPair,MODE_MAXLOT));
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void CheckOpenOrders()
  {
   int totalSell=0;
   int totalBuy=0;
   int totalPSell=0;
   int totalPBuy=0;
   TotalProfit=0;
   selldiffernce=0;
   buydiffernce=0;
   buyCount=0;
   sellCount=0;
// We need to scan all the open and pending orders to see if there are any.
// OrdersTotal returns the total number of market and pending orders.
// What we do is scan all orders and check if they are of the same symbol as the one where the EA is running.
   for(int i = 0 ; i < OrdersTotal() ; i++)
     {
      // We select the order of index i selecting by position and from the pool of market/pending trades.
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==CurrencyPair)
        {
         if((TotalGBuyOrder+TotalGSellOrder)==TotalOrder)
           {
            differnce=0;
            RemoveAllOrders();
           }
         // If the pair of the order is equal to the pair where the EA is running.
         if(OrderType()==OP_BUY)
           {
            totalBuy=totalBuy+1;
            TotalProfit=TotalProfit+OrderProfit();
           }
         if(OrderType()==OP_SELL)
           {
            TotalProfit=TotalProfit+OrderProfit();
            totalSell=totalSell+1;

           }
         if(OrderType()==OP_BUYSTOP)
           {
            totalPBuy=totalPBuy+1;


            ModifyOrderForBuyStop(OrderTicket());


           }
         if(OrderType()==OP_SELLSTOP)
           {
            totalPSell=totalPSell+1;

            ModifyOrderForSellStop(OrderTicket());

           }
        }

     }

   TotalGBuyOrder=totalBuy;
   TotalGSellOrder=totalSell;
   TotalGPBuyOrder=totalPBuy;
   TotalGPSellOrder=totalPSell;
   ShowOrderInBlock();
// If the loop finishes it mean there were no open orders for that pair.
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int selldiffernce=0;
int sellCount=0;
void ModifyOrderForSellStop(int currentOrderTicket)
  {
   double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
   if(TotalGBuyOrder>TotalGSellOrder)
     {
      Print("Order modified For Sell.");
      if(sellCount<(TotalGBuyOrder-TotalGSellOrder))
        {
         Print("Order modified Sell Condition.");
         selldiffernce=0;
         sellCount=sellCount+1;
        }
      selldiffernce=selldiffernce+PointDiffernce;
      if(AskPrice-selldiffernce>OrderOpenPrice())
        {
         bool res;
         res=  OrderModify(currentOrderTicket,(AskPrice-selldiffernce),NULL,NULL,0,Red);
         if(!res)
            Print("Error in OrderModify. Error code=",GetLastError());
         else
            Print("Order modified successfully."+OrderOpenPrice());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+d

int buydiffernce=0;
int buyCount=0;
void ModifyOrderForBuyStop(int currentOrderTicket)
  {
   double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);
   if(TotalGBuyOrder<TotalGSellOrder)
     {
      Print("Order modified For Buy.");
      if(buyCount<(TotalGSellOrder-TotalGBuyOrder))
        {
         Print("Order modified Buy Condition.");
         buydiffernce=0;
         buyCount=buyCount+1;
        }
      buydiffernce=buydiffernce+PointDiffernce;
      if(AskPrice+buydiffernce<OrderOpenPrice())
        {
         bool res;
         res= OrderModify(currentOrderTicket,(AskPrice+buydiffernce),NULL,NULL,0,Blue);
         if(!res)
            Print("Error in OrderModify. Error code=",GetLastError());
         else
            Print("Order modified successfully."+OrderOpenPrice());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderSymbol()==symbol && OrderMagicNumber()==MAGICNUM)
        {
         if(OrderType()==OP_BUYSTOP)
            buys++;
         if(OrderType()==OP_SELLSTOP)
            sells++;
        }
     }
//--- return orders volume
   if(buys>0)
      return(buys);
   else
      return(-sells);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowOrderInBlock()
  {
   string txtEquity=""+NormalizeDouble(AccountEquity(),2);
   ObjectCreate("txtEquity", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtEquity", OBJPROP_CORNER,0);
   ObjectSet("txtEquity", OBJPROP_XDISTANCE,240);
   ObjectSet("txtEquity", OBJPROP_YDISTANCE,20);
   ObjectSetText("txtEquity",txtEquity,14,"Tohoma",White);

   string txtTotalBuy="Total Buy Order = "+TotalGBuyOrder;
   ObjectCreate("txtTotalBuy", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalBuy", OBJPROP_CORNER,0);
   ObjectSet("txtTotalBuy", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalBuy", OBJPROP_YDISTANCE,40);
   ObjectSetText("txtTotalBuy",txtTotalBuy,10,"Tohoma",White);

   string txtTotalSell="Total Sell Order = "+TotalGSellOrder;
   ObjectCreate("txtTotalSell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalSell", OBJPROP_CORNER,0);
   ObjectSet("txtTotalSell", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalSell", OBJPROP_YDISTANCE,57);
   ObjectSetText("txtTotalSell",txtTotalSell,10,"Tohoma",White);



   string txtTotalPBuy="Pending Buy  Order = "+TotalGPBuyOrder;
   ObjectCreate("txtTotalPBuy", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalPBuy", OBJPROP_CORNER,0);
   ObjectSet("txtTotalPBuy", OBJPROP_XDISTANCE,150);
   ObjectSet("txtTotalPBuy", OBJPROP_YDISTANCE,40);
   ObjectSetText("txtTotalPBuy",txtTotalPBuy,10,"Tohoma",White);
   string txtTotalPSell="Pending Sell  Order = "+TotalGPSellOrder;
   ObjectCreate("txtTotalPSell", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalPSell", OBJPROP_CORNER,0);
   ObjectSet("txtTotalPSell", OBJPROP_XDISTANCE,150);
   ObjectSet("txtTotalPSell", OBJPROP_YDISTANCE,57);
   ObjectSetText("txtTotalPSell",txtTotalPSell,10,"Tohoma",White);
   TotalOrderPair=TotalGBuyOrder+TotalGPBuyOrder+TotalGPSellOrder+TotalGSellOrder;
   string txtTotalOrder="Total  Order = "+TotalOrderPair;
   ObjectCreate("txtTotalOrder", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalOrder", OBJPROP_CORNER,0);
   ObjectSet("txtTotalOrder", OBJPROP_XDISTANCE,10);
   ObjectSet("txtTotalOrder", OBJPROP_YDISTANCE,75);
   ObjectSetText("txtTotalOrder",txtTotalOrder,10,"Tohoma",White);
   string txtTotalProfit="Total Profit = "+NormalizeDouble(TotalProfit,2);
   ObjectCreate("txtTotalProfit", OBJ_LABEL, 0, 0, 0);
   ObjectSet("txtTotalProfit", OBJPROP_CORNER,0);
   ObjectSet("txtTotalProfit", OBJPROP_XDISTANCE,150);
   ObjectSet("txtTotalProfit", OBJPROP_YDISTANCE,75);
   if(TotalProfit>0)
     {
      ObjectSetText("txtTotalProfit",txtTotalProfit,12,"Arial",Blue);
     }
   else
     {
      ObjectSetText("txtTotalProfit",txtTotalProfit,12,"Arial",Red);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   CheckOpenOrders();
   Print("Timer Event");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0 ; i--)
     {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderSymbol() != CurrencyPair && removeFromThisChartOnly)
         continue;
      double price = MarketInfo(CurrencyPair,MODE_ASK);
      if(OrderType() == OP_BUY)
         price = MarketInfo(CurrencyPair,MODE_BID);
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
         OrderClose(OrderTicket(), OrderLots(),price,5);
        }
      else
        {
         OrderDelete(OrderTicket());
        }
      int error = GetLastError();
      if(error > 0)
         Print("Unanticipated error: ", error);
      RefreshRates();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrders()
  {

   if(OrderProfit()>0.30)
     {
      OrderClose(OrderTicket(),0.01,Ask,3,Red);
     }
// Update the exchange rates before closing the orders.
   RefreshRates();
// Log in the terminal the total of orders, current and past.
   Print(OrdersTotal());

// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
        {
         Print("ERROR - Unable to select the order - ", GetLastError());
         break;
        }

      // Create the required variables.
      // Result variable - to check if the operation is successful or not.
      bool res = false;

      // Allowed Slippage - the difference between current price and close price.
      int Slippage = 0;

      // Bid and Ask prices for the instrument of the order.
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      // Closing the order using the correct price depending on the type of order.
      if(OrderType() == OP_BUY)
        {
         res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
        }
      else
         if(OrderType() == OP_SELL)
           {
            res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
           }

      // If there was an error, log it.
      if(res == false)
         Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
