using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using NewCore_Application_As.DbConnection;
using NewCore_Application_As.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace NewCore_Application_As.Controllers
{
    
    public class MembershipController : Controller
    {
        private readonly AmazonDb db;

        public MembershipController(AmazonDb db)
        {
            this.db = db;
        }


        public IActionResult SignUp()
        {
            return View();
        }
        [HttpPost]
        public IActionResult SignUp(UserInfo user)
        {
            if (user != null)
            {
                db.tbl_UserInfo.Add(user);
                db.SaveChanges();
                return RedirectToAction("Login");
            }
            else
            {
                TempData["ErrorMessage"] = " Something Went Wrong Please Try Again Later";
            }
            return View();
        }

        public IActionResult Login()
        {
            return View();
        }
        [HttpPost]
        public IActionResult Login(UserInfo user)
        {
            var res = db.tbl_UserInfo.Where(m => m.Email == user.Email).FirstOrDefault();

            if (res == null)
            {
                TempData["InvalidEmail"] = "Invalid Email Address";
            }
            else
            {
                if (res.Email == user.Email && res.Password == user.Password)
                {
                    var claims = new[] { new Claim(ClaimTypes.Name, res.Name), new Claim(ClaimTypes.Email, res.Email) };

                    var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

                    var AuthProperties = new AuthenticationProperties
                    {
                        IsPersistent = true
                    };

                    HttpContext.SignInAsync(
                        CookieAuthenticationDefaults.AuthenticationScheme,
                        new ClaimsPrincipal(identity),
                        AuthProperties);


                    HttpContext.Session.SetString("Password", res.Password);
                    HttpContext.Session.SetString("Email", res.Email);

                    //ViewBag.SessionName = HttpContext.Session.GetString("Name");
                    //ViewBag.SessionEmail = HttpContext.Session.GetString("Email");

                    return RedirectToAction("Index","Home");

                }
                else
                {
                    TempData["InvalidPassword"] = "Invalid Password ! Try again";
                }
                
               
            }

            return View();
        }

        public IActionResult LogOut()
        {
            HttpContext.SignOutAsync();
            HttpContext.Session.Clear();

            return RedirectToAction("Login");
        }
    }
}
