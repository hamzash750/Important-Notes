# Important-Notes
Important Notes
===========================================
Sum Of Array
  this.totalCountmask = this.totalRecord.reduce(
        (a, b) => +a + +b.result.Count,
        0
      );
      
      
 ========================================= 
WebForm Aspx Custom Routing

 RegisterCustomRoutes(RouteTable.Routes);
        void RegisterCustomRoutes(RouteCollection routes)
        {
            routes.MapPageRoute(
                "BrowersCustomRout",
                "Browers",
                "~/myFolder/Browers.aspx"
            );
        }
Angaulr DataTable Render


  rerender(): void {
    this.tracking.getAllEmployees().subscribe(
      res => {
        this.Employees = res.body;
      },
      err => {
        console.log(err);
      }
    );
    this.dtElement.dtInstance.then((dtInstance: DataTables.Api) => {
      // Destroy the table first
      dtInstance.destroy();
      // Call the dtTrigger to rerender again
      this.dtTrigger.next();
    });
  }
  =================Ef Core Db To Schema +++++++++=====
  Scaffold-DbContext "Server=servername;Database=LT;Trusted_Connection=True;" Microsoft.EntityFrameworkCore.SqlServer -OutputDir EFCore
  
  
  
  
  
  
  
  
  
   Go to Tools -> Get Tools and features.
Select Individual components tab and check Entity Framework 6 tools under SDK's, libraries, and framework section

4)Remember you can't make an ADO.net Entity Data Model with an interface with .NET Core, its only possible with .NET Framework.
