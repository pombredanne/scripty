"""
This script creates a new profile on osum.sun.com and adds it to the College group.

How to use it?
    1. Create a CSV file named students.csv and place it in the current working directory.
    2. The format of the CSV file:
       Register_Number, First_Name, Last_Name, Month of DOB, Day of DOB, Year of DOB
       
       You can use the following query to generate the csv file from Vidyalaya Student Database

       select register_number, first_name, last_name, 
              monthname(date_of_birth), day(date_of_birth), year(date_of_birth) 
        from signup_registration
        where created_on >= '2010-06-19'
        order by register_number
        INTO OUTFILE '/tmp/students.csv'
        FIELDS TERMINATED BY ','
        LINES TERMINATED BY '\n'; 
        
    3. If there are any photos, rename them as register_number_capital.jpg and put them in photos directory 
        directly under the current working directory.
        
    4. Run Selenium Server
        java -jar /path_to_selenium/selenium-server-1.0.3/selenium-server.jar
        
    5. In another window, run this script
"""

from selenium import selenium
import unittest, time, re
import csv
import random
import time, datetime
import os


class OSUM(unittest.TestCase):
    def setUp(self):
        self.verificationErrors = []
        self.selenium = selenium("localhost", 4444, "*firefox", "http://osum.sun.com")
        self.selenium.start()
    
    def test_OSUM(self):
        
        students = csv.reader(open('students.csv'))
        
        for student in students:
            
            name = student[1] + " " + student[2]
            photo =  os.getcwd() + '/photos/' + student[0].upper() + '.jpg' 
            email_id = student[0] + "@rmv.ac.in"
            passwd = student[0].upper()
            day = student[4]
            month = student[3]
            year = student[5]
            
            
            sel = self.selenium
            sel.set_speed(1000)
            sel.delete_all_visible_cookies()

            sel.open("main/authorization/signUp")
            sel.wait_for_page_to_load("60000")
            
            sel.type("signup_email", email_id)
            sel.type("signup_password", passwd)
            sel.type("signup_password_confirm", passwd)
            sel.select("dob-month", "label=%s" % month)
            sel.select("birthdateDay", "label=%s" % day)
            sel.select("birthdateYear", "label=%s" % year)
            # Keep it long enough to manually type the CAPTCHA
            sel.wait_for_page_to_load("120000")
            
            if sel.is_text_present("has already been registered"):
                print "%s is already registered" % email_id
                continue
            
            sel.type("fullname", name)

            if os.path.exists(photo):
                sel.type("signup_avatar", photo)

            sel.select("question_24", "label=India")
            sel.select("question_25", "label=Ramakrishna Mission Vidyalaya, Coimbatore")
            sel.click("question_31_option0")
            sel.click("question_27_option0")
            sel.click("//input[@value='Join']")
            sel.wait_for_page_to_load("30000")
            
            sel.click("link=Join Now")
            sel.wait_for_page_to_load("30000")
            
            print "Processed %s" % student[0]
            with open("students_processed.txt", "a") as f:
                f.write(str(student) + " - " + str(datetime.datetime.now()) + "\n")

            sel.click("xn_signout")
            time.sleep(10)
            
            if sel.is_element_present("xn_signout"):
                sel.click("xn_signout")
                sel.wait_for_page_to_load("30000")
            
    
    def tearDown(self):
        self.selenium.stop()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
