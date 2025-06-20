import { PrismaClient, Role, UserStatus } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function createAdminUser() {
  try {
    // Hash the admin password
    const hashedPassword = await bcrypt.hash('admin123', 10);

    // Create admin user
    const adminUser = await prisma.user.create({
      data: {
        phoneNumber: '+966500000000',
        password: hashedPassword,
        fullName: 'Admin User',
        province: 'Riyadh',
        status: UserStatus.ACTIVE,
        role: Role.ADMIN,
      },
    });

    console.log('✅ Admin user created successfully!');
    console.log('📱 Phone Number:', adminUser.phoneNumber);
    console.log('🔑 Password: admin123');
    console.log('👤 Full Name:', adminUser.fullName);
    console.log('🏛️ Role:', adminUser.role);
    console.log('📍 Province:', adminUser.province);
    console.log('🆔 User ID:', adminUser.id);

  } catch (error) {
    console.error('❌ Error creating admin user:', error);
  } finally {
    await prisma.$disconnect();
  }
}

createAdminUser(); 