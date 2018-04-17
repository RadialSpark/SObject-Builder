# SObject-Builder
Collection of classes for supporting efficient and clean generation of test data

# Using a builder with no template

```
SObjectBuilder builder = new SObjectBuilder('Account');
builder
    .set('name', 'Test no template')
    .set('NumberOfEmployees', 300);
Account a = (Account)builder.validate().build(false);
```

# Using a builder with a template

```
SObjectBuilder builder = new SObjectBuilder(
  'Account', 
  new AccountTemplates.StandardAccountTemplate()
);
Account a = (Account)builder.validate().build(false);
```

# Creating lists of records

```
SObjectBuilder builder = new SObjectBuilder(
  'Account', 
  new AccountTemplates.StandardAccountTemplate()
);
builder.count(3);
List<Account> a = (List<Account>)builder.validate().build(false);
```

# Inserting record with the builder

```
Account a = (Account)builder.validate().build(true);
```

# Reseting the values of a builder

```
builder.reset();
```

# Changing templates (resets builder)

```
builder.setTemplate(new AccountTemplates.StandardAccountTemplate());
```
