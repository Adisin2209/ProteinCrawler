using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Support.UI;
using SeleniumExtras.WaitHelpers;
using System.IO; // Wichtig für Pfad-Operationen

namespace SimpleWebScraper
{
    public class Program
    {
        public static int total = 0;
        
        public class Product
        {
            public string? Name { get; set; }
            public string? Price { get; set; }
            public string? Marke { get; set; }
            public string? Laden { get; set; }
        }

        public static void Main()
        {
            var products = new List<Product>();
            var chromeOptions = new ChromeOptions();

            // --- 1. PORTABLES PROFIL-Setup ---
            string profilePath = Path.Combine(Directory.GetCurrentDirectory(), "ChromeProfile");
            chromeOptions.AddArgument("user-data-dir=" +profilePath);

            // --- 2. DYNAMISCHE MODUS-WAHL ---
            // Prüfe, ob das "Default" Profil-Verzeichnis existiert.
            // Das ist ein starkes Indiz, dass das Profil schon einmal von Chrome benutzt wurde.
            if (Directory.Exists(Path.Combine(profilePath, "Default")))
            {
                Console.WriteLine("Profil gefunden. Starte im schnellen Headless-Modus.");
                chromeOptions.AddArgument("headless");
            }
            else
            {
                Console.WriteLine("Kein Profil gefunden. Starte im sichtbaren Modus für die Ersteinrichtung.");
                // Kein Argument nötig, "sichtbar" ist der Standard.
            }

            using (var driver = new ChromeDriver(chromeOptions))
            {
                var wait = new WebDriverWait(driver, TimeSpan.FromSeconds(15));
                driver.Manage().Window.Maximize();
                
                try
                {
                    Console.WriteLine("Navigiere zur Seite...");
                    driver.Navigate().GoToUrl("https://www.marktguru.de/search/Eis");
                    
                    // --- COOKIE-BANNER BEHANDELN (NUR BEIM ERSTEN START) ---
                    try
                    {
                        var bannerContainerSelector = By.CssSelector("div[data-testid='uc-tcf-first-layer']");
                        Console.WriteLine("Suche nach Cookie-Banner (Timeout von 5 Sek)...");
                        var shortWait = new WebDriverWait(driver, TimeSpan.FromSeconds(5));
                        shortWait.Until(ExpectedConditions.ElementIsVisible(bannerContainerSelector));
                        
                        var denyButtonSelector = By.CssSelector("button[data-testid='uc-deny-all-button']");
                        shortWait.Until(ExpectedConditions.ElementToBeClickable(denyButtonSelector)).Click();
                        
                        shortWait.Until(ExpectedConditions.InvisibilityOfElementLocated(bannerContainerSelector));
                        Console.WriteLine("Cookie-Banner wurde beim ersten Start behandelt.");
                    }
                    catch (WebDriverTimeoutException)
                    {
                        Console.WriteLine("Cookie-Banner nicht gefunden. Profil ist bereits trainiert. Fahre fort...");
                    }

                   
                    
                    var productHTMLElements = driver.FindElements(By.CssSelector("li.offer-list-item"));
                    Console.WriteLine("\nExtraktion von "+productHTMLElements.Count+ "Produkten wird gestartet...");

                    foreach (var productHTMLElement in productHTMLElements)
                    {
                        string name = "N/A", price = "N/A", laden = "N/A", marke = "N/A";

                        try
                        {
                            name = productHTMLElement.FindElement(By.CssSelector("div.header h3")).Text;
                            try { laden = productHTMLElement.FindElement(By.CssSelector("dd.retailer-name a")).Text.Trim(); } catch { /* ignoriere */ }
                            try { marke = productHTMLElement.FindElement(By.CssSelector("dd.brand a")).Text.Trim(); } catch { try { marke = productHTMLElement.FindElement(By.CssSelector("dd.brand span")).Text.Trim(); } catch { /* ignoriere */ } }
                            try { price = productHTMLElement.FindElement(By.CssSelector("dd.price span.price")).Text.Trim(); } catch { try { price = productHTMLElement.FindElement(By.CssSelector("span.offer-price-v2__price")).Text.Trim(); } catch { /* ignoriere */ } }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine("Fehler bei der Verarbeitung eines Elements:" +ex.GetType().Name+". Wird übersprungen.");
                            continue;
                        }

                        var product = new Product() { Name = name, Price = price, Marke = marke, Laden = laden };
                        products.Add(product);
                        total++;

                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("\nEin schwerwiegender Fehler ist aufgetreten: "+ ex.GetType().Name + ex.Message);
                }
            }

            // --- 5. FINALE AUSGABE ---
            Console.WriteLine("\n--- Gespeicherte Produkte ---");
            foreach (var p in products)
            {
                Console.WriteLine($"Name: {p.Name,-30} | Preis: {p.Price,-8} | Marke: {p.Marke,-20} | Laden: {p.Laden}");
            }
        }
    }
}