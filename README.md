# Important-Notes
Important Notes

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
