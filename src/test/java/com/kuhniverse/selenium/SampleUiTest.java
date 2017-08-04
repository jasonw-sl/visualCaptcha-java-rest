package com.kuhniverse.selenium;
import io.ddavison.conductor.Browser;
import io.ddavison.conductor.Config;
import io.ddavison.conductor.Locomotive;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
@Config(
        browser = Browser.CHROME,
        url = "http://localhost:8888/"
)
public class SampleUiTest extends Locomotive {
    @Before
    public void setup() {
        this.driver.manage().window().maximize();
    }
    @Test
    public void testMoise() throws InterruptedException {
        MainPage mainPage = new MainPage();
        mainPage.enterName("moise");
        mainPage.selectItem(1);
        mainPage.submitForm();
        Assert.assertFalse(false);
    }
    @Test
    public void testSimon() throws InterruptedException {
        MainPage mainPage = new MainPage();
        mainPage.enterName("Simon");
        mainPage.selectItem(2);
        Assert.assertFalse(false);
    }
    private class MainPage {
        public static final String TXT_NAME = ".form-control";
        public static final String BTN_SUBMIT_FORM = ".submit";
        public void enterName(String name) {
            setText(TXT_NAME, name);
        }
        public void submitForm(){
            click(BTN_SUBMIT_FORM);
        }
        public void selectItem(int index){
            click("[data-index='"+index+"']");
        }
    }
}
