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
