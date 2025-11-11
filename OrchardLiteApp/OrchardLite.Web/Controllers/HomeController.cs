using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MySql.Data.MySqlClient;
using OrchardLite.Web.Models;

namespace OrchardLite.Web.Controllers
{
    public class HomeController : Controller
    {
        private readonly IConfiguration _configuration;

        public HomeController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        private string GetConnectionString()
        {
            var connStr = _configuration.GetConnectionString("OrchardLiteDB");
            
            // Replace environment variables
            connStr = connStr
                .Replace("${DB_HOST}", Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost")
                .Replace("${DB_PORT}", Environment.GetEnvironmentVariable("DB_PORT") ?? "3306")
                .Replace("${DB_NAME}", Environment.GetEnvironmentVariable("DB_NAME") ?? "OrchardLiteDB")
                .Replace("${DB_USER}", Environment.GetEnvironmentVariable("DB_USER") ?? "root")
                .Replace("${DB_PASSWORD}", Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "password");
            
            return connStr;
        }

        public IActionResult Index()
        {
            try
            {
                var contentItems = new List<ContentItem>();
                int totalRecords = 0;

                using (var connection = new MySqlConnection(GetConnectionString()))
                {
                    connection.Open();

                    // Get total count
                    using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM ContentItems", connection))
                    {
                        totalRecords = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Get recent posts
                    using (var cmd = new MySqlCommand("SELECT * FROM ContentItems ORDER BY PublishedDate DESC LIMIT 20", connection))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            contentItems.Add(new ContentItem
                            {
                                Id = reader.GetInt32("Id"),
                                Title = reader.GetString("Title"),
                                Summary = reader.IsDBNull(reader.GetOrdinal("Summary")) ? "" : reader.GetString("Summary"),
                                Body = reader.IsDBNull(reader.GetOrdinal("Body")) ? "" : reader.GetString("Body"),
                                ContentType = reader.GetString("ContentType"),
                                AuthorId = reader.GetInt32("AuthorId"),
                                PublishedDate = reader.GetDateTime("PublishedDate"),
                                ViewCount = reader.GetInt32("ViewCount"),
                                IsPublished = reader.GetBoolean("IsPublished"),
                                CreatedDate = reader.GetDateTime("CreatedDate")
                            });
                        }
                    }
                }

                ViewBag.TotalRecords = totalRecords;
                ViewBag.DbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
                ViewBag.DbPort = Environment.GetEnvironmentVariable("DB_PORT") ?? "3306";
                ViewBag.DotNetVersion = ".NET Core 3.1";
                ViewBag.DatabaseType = "RDS MySQL 8.0";

                return View(contentItems);
            }
            catch (Exception ex)
            {
                ViewBag.Error = ex.Message;
                ViewBag.DbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
                return View("Error");
            }
        }

        public IActionResult AllContent()
        {
            try
            {
                var contentItems = new List<ContentItem>();

                using (var connection = new MySqlConnection(GetConnectionString()))
                {
                    connection.Open();

                    using (var cmd = new MySqlCommand("SELECT * FROM ContentItems ORDER BY PublishedDate DESC", connection))
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            contentItems.Add(new ContentItem
                            {
                                Id = reader.GetInt32("Id"),
                                Title = reader.GetString("Title"),
                                Summary = reader.IsDBNull(reader.GetOrdinal("Summary")) ? "" : reader.GetString("Summary"),
                                Body = reader.IsDBNull(reader.GetOrdinal("Body")) ? "" : reader.GetString("Body"),
                                ContentType = reader.GetString("ContentType"),
                                AuthorId = reader.GetInt32("AuthorId"),
                                PublishedDate = reader.GetDateTime("PublishedDate"),
                                ViewCount = reader.GetInt32("ViewCount"),
                                IsPublished = reader.GetBoolean("IsPublished"),
                                CreatedDate = reader.GetDateTime("CreatedDate")
                            });
                        }
                    }
                }

                ViewBag.TotalRecords = contentItems.Count;
                return View(contentItems);
            }
            catch (Exception ex)
            {
                ViewBag.Error = ex.Message;
                return View("Error");
            }
        }

        public IActionResult Health()
        {
            var health = new
            {
                status = "OK",
                phase = "Phase 1 - Current State",
                dotnetVersion = ".NET Core 3.1",
                deploymentType = "CloudFormation Automated",
                databaseType = "RDS MySQL 8.0",
                databaseHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost",
                timestamp = DateTime.UtcNow.ToString("o")
            };

            return Json(health);
        }
    }
}
