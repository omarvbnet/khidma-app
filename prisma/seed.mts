import { PrismaClient, TaxiRequest_status, Role } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

function randomPhone() {
  return `+9665${Math.floor(10000000 + Math.random() * 90000000)}`;
}

function randomProvince() {
  const provinces = ['Riyadh', 'Jeddah', 'Dammam', 'Mecca', 'Medina'];
  return provinces[Math.floor(Math.random() * provinces.length)];
}

function randomTripType() {
  const types = ['ECO', 'VIP', 'SPECIAL'];
  return types[Math.floor(Math.random() * types.length)];
}

function randomStatus() {
  const statuses = [
    TaxiRequest_status.WAITING,
    TaxiRequest_status.IN_WAY,
    TaxiRequest_status.CHECK_OUT,
    TaxiRequest_status.ARRIVED,
  ];
  return statuses[Math.floor(Math.random() * statuses.length)];
}

async function main() {
  // Delete existing data in the correct order to handle foreign key constraints
  await prisma.taxiRequest.deleteMany({});
  await prisma.order.deleteMany({});
  await prisma.driverLog.deleteMany({});
  await prisma.driver.deleteMany({});
  await prisma.user.deleteMany({});

  // Create admin user
  const adminPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.create({
    data: {
      email: 'admin@khidma.com',
      fullName: 'Admin User',
      password: adminPassword,
      role: Role.ADMIN,
      status: 'ACTIVE',
      phoneNumber: '+966500000000',
      province: 'Riyadh',
      budget: 0,
    },
  });

  // Create regular user
  const userPassword = await bcrypt.hash('user123', 10);
  const user = await prisma.user.create({
    data: {
      email: 'user@khidma.com',
      fullName: 'Regular User',
      password: userPassword,
      role: Role.USER,
      status: 'ACTIVE',
      phoneNumber: '+966500000001',
      province: 'Riyadh',
      budget: 1000,
    },
  });

  // Create driver
  const driverPassword = await bcrypt.hash('driver123', 10);
  const driver = await prisma.user.create({
    data: {
      email: 'driver@khidma.com',
      fullName: 'Driver User',
      password: driverPassword,
      role: Role.DRIVER,
      status: 'ACTIVE',
      phoneNumber: '+966500000002',
      province: 'Riyadh',
      budget: 0,
      driver: {
        create: {
          carId: 'CAR123',
          carType: 'Sedan',
          licenseId: 'LICENSE123',
          carImage: 'https://example.com/car.jpg',
          licenseImage: 'https://example.com/license.jpg',
          driverImage: 'https://example.com/driver.jpg',
          rate: 4.5,
        },
      },
    },
    include: {
      driver: true,
    },
  });

  // Add 10 more users
  const moreUserPromises = [];
  for (let i = 0; i < 10; i++) {
    moreUserPromises.push(
      prisma.user.create({
        data: {
          fullName: `User ${i + 3}`,
          email: `user${i + 3}@example.com`,
          password: await bcrypt.hash('password123', 12),
          role: 'USER',
          phoneNumber: randomPhone(),
          province: randomProvince(),
          budget: Math.floor(500 + Math.random() * 2000),
        },
      })
    );
  }
  const moreUsers = await Promise.all(moreUserPromises);

  // Add 5 more drivers
  const moreDriverPromises = [];
  for (let i = 0; i < 5; i++) {
    moreDriverPromises.push(
      prisma.user.create({
        data: {
          fullName: `Driver ${i + 2}`,
          email: `driver${i + 2}@example.com`,
          password: await bcrypt.hash('password123', 12),
          role: 'DRIVER',
          phoneNumber: randomPhone(),
          province: randomProvince(),
          budget: 0,
          driver: {
            create: {
              carId: `CAR${i + 2}`,
              carType: ['Sedan', 'SUV', 'Hatchback'][i % 3],
              licenseId: `LIC${i + 2}`,
              rate: Math.round((3.5 + Math.random() * 1.5) * 10) / 10,
            },
          },
        },
        include: {
          driver: true,
        },
      })
    );
  }
  const moreDrivers = await Promise.all(moreDriverPromises);

  // All users and drivers
  const allUsers = [admin, user, ...moreUsers];
  const allDrivers = [driver, ...moreDrivers];

  // Create base taxi requests
  await prisma.taxiRequest.create({
    data: {
      userId: user.id,
      status: TaxiRequest_status.WAITING,
      pickup: 'King Abdullah Road, Riyadh',
      destination: 'Olaya Street, Riyadh',
      tripType: 'ECO',
      requester_id: user.id,
      requester_name: user.fullName,
      tripCost: 50,
    },
  });

  await prisma.taxiRequest.create({
    data: {
      userId: user.id,
      status: TaxiRequest_status.IN_WAY,
      pickup: 'Tahlia Street, Jeddah',
      destination: 'Corniche Road, Jeddah',
      tripType: 'VIP',
      requester_id: user.id,
      requester_name: user.fullName,
      driverId: driver.id,
      driverName: driver.fullName,
      driverPhone: driver.phoneNumber,
      tripCost: 75,
    },
  });

  await prisma.taxiRequest.create({
    data: {
      userId: user.id,
      status: TaxiRequest_status.ARRIVED,
      pickup: 'King Fahd Road, Riyadh',
      destination: 'Prince Mohammed Street, Riyadh',
      tripType: 'SPECIAL',
      requester_id: user.id,
      requester_name: user.fullName,
      driverId: driver.id,
      driverName: driver.fullName,
      driverPhone: driver.phoneNumber,
      tripCost: 100,
      paymentStatus: 'PAID',
    },
  });

  // Add 20 more taxi requests
  for (let i = 0; i < 20; i++) {
    const user = allUsers[Math.floor(Math.random() * allUsers.length)];
    const driver = allDrivers[Math.floor(Math.random() * allDrivers.length)];
    await prisma.taxiRequest.create({
      data: {
        userId: user.id,
        status: randomStatus(),
        pickup: `Pickup Location ${i + 1}`,
        destination: `Destination ${i + 1}`,
        tripType: randomTripType(),
        requester_id: user.id,
        requester_name: user.fullName,
        driverId: driver.id,
        driverName: driver.fullName,
        driverPhone: driver.phoneNumber,
        tripCost: Math.floor(30 + Math.random() * 120),
        paymentStatus: Math.random() > 0.5 ? 'PAID' : 'UNPAID',
      },
    });
  }

  // Create test orders
  await prisma.order.create({
    data: {
      userId: user.id,
      status: 'COMPLETED',
      total: 150,
      province: 'Riyadh',
    },
  });

  await prisma.order.create({
    data: {
      userId: user.id,
      status: 'PENDING',
      total: 200,
      province: 'Jeddah',
    },
  });

  // Create test products
  await prisma.product.create({
    data: {
      name: 'Basic Service',
      price: 50,
      description: 'Standard taxi service',
    },
  });

  await prisma.product.create({
    data: {
      name: 'Premium Service',
      price: 100,
      description: 'Luxury car service',
    },
  });

  console.log('Seed data created successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 