/*********************************************
 * OPL  Model
 * Author: Micha³ Lutoborski
 * Creation Date: 26-05-2016 at 19:41:49
 *********************************************/

// Wczytywanie parametrów
int nbMachines = ...;
int nbMonths = ...;
int nbProducts = ...;

int distrColNb = ...;
int distrRowNb = ...;

// Utworzenie wektorów do indeksowania
{int} machines = asSet(1..nbMachines);
{int} months = asSet(1..nbMonths);
{int} products = asSet(1..nbProducts);
{int} distrCol = asSet(1..distrColNb);
{int} distrRow = asSet(1..distrRowNb);

int maxMachines[machines] = ...;

float prodCost[machines][products] = ...;
			
int monthMax[months][products] = ...;

int storageMax[products] = ...;
int storageCost = ...;

int nbHours = ...;

int mi[distrCol] = ...;

int covariance[distrCol][distrCol] = ...;

float sellProfitR[distrRow][distrCol] = ...;

// MPO
float asAvgProfit = ...;
float utAvgProfit = ...;
float ndAvgProfit = ...;
float lmbAvgProfit = 1/(utAvgProfit - ndAvgProfit);

float asMaxRisk = ...;
float utMaxRisk = ...;
float ndMaxRisk = ...;
float lmbMaxRisk = 1/(ndMaxRisk - utMaxRisk); // Dla ryzyka utopia <= nadiru, wiêc odwracamy znaki, ¿eby lambda > 0

float beta = ...;
float epsilon = ...;


// Zmienne decyzyjne
dvar int producedQuant[months][products]; 	// Liczba wyprodukowanych
dvar int soldQuant[months][products];		// Liczba sprzedanych
dvar int stockQuant[months][products];		// Liczba w magazynie
dvar float elapsedTime[months][machines][products];	// Czas wykorzystany na maszynach na dane produkty

// MPO
dvar float z;
dvar float mpoAvgProfit;
dvar float mpoMaxRisk;

// Kryteria
dexpr float profit[i in distrRow] = sum(m in months, p in products) (soldQuant[m][p]*sellProfitR[i][p] - stockQuant[m][p]*storageCost);
dexpr float avgProfit = sum(i in distrRow)(profit[i])/distrRowNb;

dexpr float risk[i in distrRow] = abs(avgProfit-profit[i]);
dexpr float maxRisk = max(i in distrRow) risk[i];

dexpr float objective = z + epsilon*(mpoAvgProfit + mpoMaxRisk);

// Funkcja celu
maximize objective;

// Ograniczenia
subject to {
  // Wiêksze ni¿ 0
  forall(m in months, mc in machines, p in products) {
    elapsedTime[m][mc][p] >= 0;
    producedQuant[m][p] >= 0;
    soldQuant[m][p] >= 0;
    stockQuant[m][p] >= 0;
  }    
  
  // Produkcja
  
	forall(m in months, mc in machines) {
	  sum(p in products) (elapsedTime[m][mc][p]) <= maxMachines[mc]*nbHours;
  }
   	
 	forall(m in months, p in products, mc in machines) {
 	  elapsedTime[m][mc][p] == producedQuant[m][p]*prodCost[mc][p];
  }
  
  	forall(m in months, mc in products, p in products) {
 	  elapsedTime[m][mc][p] <= nbHours;
  }
	
  // Rynek
 	forall(m in months, p in products) {
 	  soldQuant[m][p] <= monthMax[m][p];
  }
  	
  	forall(m in months, p in products) {
  	  if(m == 1) {
  	    soldQuant[m][p] == producedQuant[m][p];
     }
     else {
       soldQuant[m][p] == producedQuant[m][p] + stockQuant[m-1][p];
     }
  }
  
    /* Warunek sprzedawania produktów P4 w miesi¹cach w których sprzedawany jest P1 lub P2 mo¿na rozumieæ dwojako.
    Je¿eli mamy sprzedawaæ P4 jednoczeœnie z produktem P1 lub P2, to warunek jest prosty: suma sprzedanych P1 i P2 w danym miesi¹cu
    musi byæ równa sprzedanej P4. - warunek jest aktualnie zakodowany w skrypcie poni¿ej tego komentarza, przetestowany i dzia³a.
    W przypadku gdy iloœci nie musz¹ siê pokrywaæ problem jest do rozwi¹zania.
    Wprowadziæ poprawkê po konsultacjach z prowadz¹cym.
    */
  	
  	forall(m in months) {
  	  soldQuant[m][1] + soldQuant[m][2] == soldQuant[m][4];
   }
  
  // Sk³ad
  	forall(m in months, p in products) {
  	  stockQuant[m][p] <= storageMax[p];
  	  if(m == 3) {
  	  	stockQuant[m][p] >= 50;
    }  	  	
   }
   
   // MPO
   z <= mpoAvgProfit;
   z <= mpoMaxRisk;
   
   mpoAvgProfit <= beta * lmbAvgProfit * (avgProfit - asAvgProfit);
   mpoAvgProfit <= lmbAvgProfit * (avgProfit - asAvgProfit);
   
   mpoMaxRisk <= beta * lmbMaxRisk * (asMaxRisk - maxRisk);
   mpoMaxRisk <= lmbMaxRisk * (asMaxRisk - maxRisk);   
}

main {
   var file = new IloOplOutputFile("wyniki.txt");
   var fileRA = new IloOplOutputFile("risk.txt");
   
   var mod  = thisOplModel;
   var def  = mod.modelDefinition;
   var data = mod.dataElements;
   var maxAvgProfit = 20000;	// 20000
   var maxMaxRisk = 4800;		// 4800
   var i = 1;
   
   file.writeln("m1_prod_P1;m1_prod_P2;m1_prod_P3;m1_prod_P4;m2_prod_P1;m2_prod_P2;m2_prod_P3;m2_prod_P4;m3_prod_P1;m3_prod_P2;m3_prod_P3;m3_prod_P4;m1_stock_P1;m1_stock_P2;m1_stock_P3;m1_stock_P4;m2_stock_P1;m2_stock_P2;m2_stock_P3;m2_stock_P4;m3_stock_P1;m3_stock_P2;m3_stock_P3;m3_stock_P4;asAvgProfit;avgProfit;asMaxRisk;maxRisk;objective");
   
   data.asMaxRisk = 0;
    
   while (data.asMaxRisk <= maxMaxRisk)	{
     data.asAvgProfit = -200;
     
     while (data.asAvgProfit <= maxAvgProfit) {
       mod = new IloOplModel (def, cplex);
       mod.addDataSource(data);
       mod.generate();
       
       cplex.solve();
       file.writeln(mod.producedQuant[1][1],";",mod.producedQuant[1][2],";",mod.producedQuant[1][3],";",mod.producedQuant[1][4], ";",mod.producedQuant[2][1],";",mod.producedQuant[2][2],";",mod.producedQuant[2][3],";",mod.producedQuant[2][4],";",mod.producedQuant[3][1],";",mod.producedQuant[3][2], ";",mod.producedQuant[3][3],";",mod.producedQuant[3][4],";",mod.stockQuant[1][1],";",mod.stockQuant[1][2],";",mod.stockQuant[1][3],";",mod.stockQuant[1][4], ";",mod.stockQuant[2][1],";",mod.stockQuant[2][2],";",mod.stockQuant[2][3],";",mod.stockQuant[2][4],";",mod.stockQuant[3][1],";",mod.stockQuant[3][2], ";",mod.stockQuant[3][3],";",mod.stockQuant[3][4],";",data.asAvgProfit,";",mod.avgProfit,";",data.asMaxRisk,";",mod.maxRisk,";",cplex.getObjValue());
     writeln(i);
/*       writeln("");
       writeln("amtK1_F1: ", mod.amtK1_F1);
       writeln("amtK1_F2: ", mod.amtK1_F2);
       writeln("amtK1_M2: ", mod.amtK1_M2);
       writeln("amtK2_F1: ", mod.amtK2_F1);
       writeln("amtK2_M1: ", mod.amtK2_M1);
       writeln("amtK2_M2: ", mod.amtK2_M2);
       writeln("avgCost: ", mod.avgCost);
       writeln("whlRisk: ", mod.whlRisk);		*/
       mod.end();
       data.asAvgProfit = data.asAvgProfit + 808;
       i = i+1;
     };
     
     data.asMaxRisk = data.asMaxRisk + 320;
   };
   
   file.close();   
 }   
 
 /*
  		   
   
   if(data.uMPO==1 && data.uASP==0)
   {
   // Change the aspiration level
  }
  else if(data.uMPO==1 && data.uASP==1)
  {
  		fileRA.writeln("amtK1_F1;amtK1_F2;amtK1_M2;amtK2_F1;amtK2_M1;amtK2_M2;AvgCostAsp;RiskAsp;AvgCost;Risk;Solution");
   		
   		data.asWhlRisk = 15;    
   		data.asAvgCost = 320;
   		
     	mod = new IloOplModel (def, cplex);
   		mod.addDataSource(data);
   		mod.generate();
   		  
   		cplex.solve();
        fileRA.writeln(mod.amtK1_F1,";",mod.amtK1_F2,";",mod.amtK1_M2,";",mod.amtK2_F1, ";",mod.amtK2_M1,";",mod.amtK2_M2,";",data.asAvgCost,";",data.asWhlRisk,";",mod.avgCost,";",mod.whlRisk,";",cplex.getObjValue());
        
        i = 1;
        
        fileRA.writeln("Cost: ");            
        while (i<=data.nrows)
        {
        fileRA.writeln(mod.cost[i]);
        i++;
        };   
        
        i = 1;
        
        fileRA.writeln("Risk: ");
         while (i<=data.nrows)
        {
         fileRA.writeln(mod.risk[i]);
         i++;
         };    
        
        data.asWhlRisk = 30;    
   		data.asAvgCost = 260;
   		
     	mod = new IloOplModel (def, cplex);
   		mod.addDataSource(data);
   		mod.generate();
   		  
   		cplex.solve();
        fileRA.writeln(mod.amtK1_F1,";",mod.amtK1_F2,";",mod.amtK1_M2,";",mod.amtK2_F1, ";",mod.amtK2_M1,";",mod.amtK2_M2,";",data.asAvgCost,";",data.asWhlRisk,";",mod.avgCost,";",mod.whlRisk,";",cplex.getObjValue());
        
        i = 1;
        
        fileRA.writeln("Cost: ");            
        while (i<=data.nrows)
        {
        fileRA.writeln(mod.cost[i]);
        i++;
        };   
        
        i = 1;
        
        fileRA.writeln("Risk: ");
         while (i<=data.nrows)
        {
         fileRA.writeln(mod.risk[i]);
         i++;
         };    
        
        data.asWhlRisk = 10;    
   		data.asAvgCost = 380;
   		
     	mod = new IloOplModel (def, cplex);
   		mod.addDataSource(data);
   		mod.generate();
   		  
   		cplex.solve();
        fileRA.writeln(mod.amtK1_F1,";",mod.amtK1_F2,";",mod.amtK1_M2,";",mod.amtK2_F1, ";",mod.amtK2_M1,";",mod.amtK2_M2,";",data.asAvgCost,";",data.asWhlRisk,";",mod.avgCost,";",mod.whlRisk,";",cplex.getObjValue());
        
        i = 1;
        
        fileRA.writeln("Cost: ");            
        while (i<=data.nrows)
        {
        fileRA.writeln(mod.cost[i]);
        i++;
        };   
        
        i = 1;
        
        fileRA.writeln("Risk: ");
         while (i<=data.nrows)
        {
         fileRA.writeln(mod.risk[i]);
         i++;
         };    
                    
    
  	fileRA.close();   
  }
  else
  { 
  		mod.generate();
  		cplex.solve();
  		writeln("");
  		writeln("amtK1_F1: ", mod.amtK1_F1);
        writeln("amtK1_F2: ", mod.amtK1_F2);
        writeln("amtK1_M2: ", mod.amtK1_M2);
        writeln("amtK2_F1: ", mod.amtK2_F1);
        writeln("amtK2_M1: ", mod.amtK2_M1);
        writeln("amtK2_M2: ", mod.amtK2_M2);
        writeln("avgCost: ", mod.avgCost);
        writeln("whlRisk: ", mod.whlRisk);
  		mod.end();
  }; 		
};

*/