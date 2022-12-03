money = 12
price_cola = 100
price_water = 30 
price_milk = 60 

if money >= price_cola:
    print('we can buy cola')
elif money >= price_milk and money < price_cola:
    print('we can buy milk')
elif  money >= price_water and money <= price_milk:
    print('we can buy milk')
else:
    print('we dont even have enough money for water')    

print("Программа работает успешно")